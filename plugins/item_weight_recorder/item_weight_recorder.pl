package OpenKore::Plugins::ItemWeightRecorder;
###############################################################################
# Record item weights into tables/item_weights.txt.
# Also supports Actor::Item->weight.

use strict;

use Globals qw( $char );
use Time::HiRes qw( &time );
use Log qw(message error debug warning);
use Misc qw(parseReload itemNameSimple);

our $name = 'item_weight_recorder';

my $file_handle;
my $filename = 'item_weights.txt';
my $item_weights = {};
loadFiles();


# Tracking inventory changes seems unnecessary, but it works around a specific
# failure case: when attempting to add an item to inventory/storage/cart fails
# (usually due to being overweight) the server sends an add AND remove for the
# same item.
our $inventory_changes;
our $last_item;
our $last_weight;

Plugins::register( $name, "$name plugin", \&Unload, \&Unload );

my $hooks = Plugins::addHooks(    #
	[ 'get_item_weight'             => \&onGetItemWeight ],
	[ 'packet/inventory_item_added' => \&onInventoryItemAdded ],
	[ 'inventory_item_removed'      => \&onInventoryItemRemoved ],
	[ 'packet/stat_info'            => \&onStatInfo ],
	[ 'packet/item_used'            => \&onItemUsed ],
);

my $commands_hooks = Commands::register(
	['getweight', 'get item weight',			\&cmdPrintWeight],
);

sub Unload {
	Plugins::delHooks($hooks);
	Commands::unregister($commands_hooks);
	Settings::removeFile($file_handle) if (defined $file_handle);
	undef $file_handle;
	undef $filename;
	undef $item_weights;
}

sub cmdPrintWeight {
	if (!defined $_[1]) {
		message "usage: getweight [item ID]\n", "list";
		return;
	}
	my ( $command, $arg ) = @_;
	
	my $id = $arg;
	
	if ($id !~ /^\d+$/) {
		message "Provided item ID is not numerical\n", "list";
		return;
	}
	
	if (!exists $item_weights->{ $arg }) {
		warning "[$name] The weight of item id $arg is not defined\n";
	} else {
		my $name = Misc::itemNameSimple($arg);
		warning "[$name] The weight of item id $arg (".$name.") is ".$item_weights->{ $arg }."\n";
	}
}

sub loadFiles {
	$file_handle = setLoad($filename);
	Settings::loadByHandle($file_handle);
}

sub setLoad {
	my $filename = shift;
	my $handle = Settings::addTableFile(
		$filename,
		loader => [ \&FileParsers::parseDataFile2, $item_weights ],
		internalName => $filename,
		mustExist => 0
	);
	return $handle;
}

sub onGetItemWeight {
	my ( undef, $args ) = @_;
	$args->{weight} = $item_weights->{ $args->{nameID} };
}

sub onInventoryItemAdded {
	my ( undef, $args ) = @_;

	return if $args->{fail};

	my $item = $char->inventory->getByID( $args->{ID} );
	return if !$item || !$args->{amount};

	# Weight updates to equipped items happen in reverse order. Ignore changes to them.
	return if $item->{equipped};

	$last_item = { item_id => $item->{nameID}, amount => $args->{amount}, time => time };
	$inventory_changes++;
}

sub onInventoryItemRemoved {
	my ( undef, $args ) = @_;
	return if $args->{item}->{equipped};
	$last_item = { item_id => $args->{item}->{nameID}, amount => $args->{amount}, time => time };
	$inventory_changes++;
}

# The server sends weight changes immediately after each inventory change.
sub onStatInfo {
	my ( undef, $args ) = @_;

	# 0x18 is WEIGHT.
	return if $args->{type} != 0x18;

	# Ignore item changes from more than one second ago. This might result
	# in some false negatives, but should also prevent some false positives.
	if ( $inventory_changes == 1 && defined $last_weight && !Utils::timeOut( $last_item->{time}, 1 ) ) {
		my $weight = abs( $args->{val} - $last_weight ) / $last_item->{amount};
		if ( !exists $item_weights->{ $last_item->{item_id} } || $item_weights->{ $last_item->{item_id} } != $weight ) {
			$item_weights->{ $last_item->{item_id} } = $weight;
			Log::warning( sprintf( "Item [%s] (%d) has weight %d (/10).\n", Misc::itemNameSimple($last_item->{item_id}), $last_item->{item_id}, $weight ), $name );
			filewrite( $filename, $last_item->{item_id}, $weight, Misc::itemNameSimple($last_item->{item_id}) );
		}
	}
	$last_item         = undef;
	$last_weight       = $args->{val};
	$inventory_changes = 0;
}

# The packet sequence here is: weight, item_used, inventory_removed.
# Ignore the next inventory change to avoid a false positive.
sub onItemUsed {
    $inventory_changes++;
}

## write FILE
sub filewrite {
	my ($file, $key, $value, $name) = @_;
	my @value;
	my $controlfile = Settings::getTableFilename($file);
	debug "sub WRITE = FILE: $file\nKEY: $key\nVALUE: $value\nNAME: $name\n";

	open(FILE, "<:encoding(UTF-8)", $controlfile);
	my @lines = <FILE>;
	close(FILE);
	chomp @lines;
	
	my @new_lines;

	my $used = 0;
		@value = split(/\s+/, $value);
		my $index = 0;
		foreach my $line (@lines) {
			my ($what) = $line =~ /([\s\S]+?)\s[\-\d\.]+[\s\S]*/;
			$what =~ s/\s+$//g;
			$what =~ s/\"$//g;
			$what =~ s/^\"//g;
			$what = lc($what);
			my $tmp;
			if ($what == $key) {
				debug "Found old in line $index: $line\n";
			} else {
				push (@new_lines, $line);
			}
		} continue {
			$index++;
		}
		
		my $new_value = $key.' '.$value. " # ". $name;
		
		debug "New record in line $index: $new_value\n";
		
		push (@new_lines, $new_value);
	
	open(WRITE, ">:utf8", $controlfile);
	print WRITE join ("\n", @new_lines);
	close(WRITE);
	parseReload($file);
}

1;
