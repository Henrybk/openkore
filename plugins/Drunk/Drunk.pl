package Drunk;

use utf8;
use strict;
use warnings;
use File::Spec;
use FileParsers;
use Plugins;
use Settings;
use Globals;
use Log qw(message error debug warning);

our $folder = $Plugins::current_plugin_folder;
use lib $Plugins::current_plugin_folder;

XSLoader::load('DrunkPath');

use DrunkPath;

Plugins::register('Drunk', 'Drunk', \&Unload, \&Unload);

use constant {
	PLUGIN_NAME => 'Drunk',
};

sub Unload {
	message "[".PLUGIN_NAME."] Plugin unloading or reloading.\n", 'success';
}

1;