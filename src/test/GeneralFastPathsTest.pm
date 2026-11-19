package GeneralFastPathsTest;
use strict;
use warnings;
use Test::More;
use FindBin qw($RealBin);
use lib "$RealBin/../../plugins/eventMacro";
use Globals;
use AI;
use AI::CoreLogic;
use Misc;
use Log ();
use eventMacro::Core;

{
    package GeneralFastPathsTest::Sender;
    sub sendEmotion { push @{$_[0]{emotions}}, $_[1] }
}
{
    package GeneralFastPathsTest::Inventory;
    sub isReady { 1 }
}
{
    package GeneralFastPathsTest::Char;
    sub inventory { $_[0]{inventory} }
}
{
    package GeneralFastPathsTest::DeferredValue;
    use overload '""' => sub { my $r = shift; $$r++; return 'VALUE' }, fallback => 1;
}

sub start {
    subtest 'actor avoidance does not calculate position before its timeout' => sub {
        local %Globals::config = (clientSight => 14);
        local %Globals::timeout = (avoidDistantActors => {time => 1, timeout => 30});
        my $position_calls = 0;
        no warnings 'redefine';
        local *AI::CoreLogic::timeOut = sub { 0 };
        local *AI::CoreLogic::calcPosFromPathfinding = sub { $position_calls++; die 'unexpected position calculation' };
        AI::CoreLogic::processActorAvoid();
        is($position_calls, 0, 'no path position calculation before timed actor scan');
    };

    subtest 'inactive automation returns before evaluating expensive prerequisites' => sub {
        local %Globals::config;
        local $Globals::char = bless {muted => 0}, 'GeneralFastPathsTest::Char';
        local $Globals::monstersList = [];
        no warnings 'redefine';
        local *AI::inQueue = sub { 0 };
        local *AI::isIdle = sub { die 'unexpected AI state scan' };
        AI::CoreLogic::processMonsterSkillUse();
        pass('monster skill scan skipped with no monsters');
        AI::CoreLogic::processAllowedMaps();
        AI::CoreLogic::processDcOnPlayer();
        AI::CoreLogic::processRepairAuto();
        pass('inactive map, disconnect and repair handlers did not inspect unavailable services');
    };

    subtest 'empty auto-equip scan preserves timer cadence' => sub {
        local %Globals::config;
        local %Globals::timeout = (ai_item_equip_auto => {time => 0, timeout => 1});
        local $Globals::char = bless {
            inventory => bless({}, 'GeneralFastPathsTest::Inventory')
        }, 'GeneralFastPathsTest::Char';
        no warnings 'redefine';
        local *AI::isIdle = sub { 1 };
        local *AI::CoreLogic::timeOut = sub { 1 };
        local *AI::findAction = sub { die 'unexpected attack lookup' };
        AI::CoreLogic::processAutoEquip();
        ok($Globals::timeout{ai_item_equip_auto}{time} > 0, 'empty scan advances its existing timer');
    };

    subtest 'sendEmotion uses the arguments for the located queue entry' => sub {
        local $Globals::messageSender = bless {emotions => []}, 'GeneralFastPathsTest::Sender';
        my ($seen_index, $cleared);
        no warnings 'redefine';
        local *AI::findAction = sub { 2 };
        local *AI::args = sub {
            $seen_index = $_[0];
            return {timeout => 0, emotion => 17} if $_[0] == 2;
            die 'wrong queue entry accessed';
        };
        local *AI::clear = sub { $cleared = $_[0] };
        AI::CoreLogic::processSendEmotion();
        is($seen_index, 2, 'reads the selected sendEmotion entry');
        is_deeply($Globals::messageSender->{emotions}, [17], 'sends the selected emotion');
        is($cleared, 'sendEmotion', 'removes the completed queued action');
    };

    subtest 'eventMacro callback diagnostic is lazy without changing variable processing' => sub {
        my $core = bless {}, 'eventMacro::Core';
        my @messages;
        my $stringifications = 0;
        my $value = bless \$stringifications, 'GeneralFastPathsTest::DeferredValue';
        my $enabled = 0;
        no warnings 'redefine';
        local *Log::debugEnabled = sub { return $enabled };
        local *eventMacro::Core::debug = sub { push @messages, [@_] };
        $core->manage_event_callbacks('variable', 'foo', $value, {}, 'accessed_array', 3);
        is($stringifications, 0, 'disabled diagnostic does not stringify callback payload');
        is_deeply(\@messages, [], 'disabled diagnostic emits no message');

        $enabled = 1;
        $core->manage_event_callbacks('variable', 'foo', $value, {}, 'accessed_array', 3);
        is($stringifications, 1, 'enabled diagnostic stringifies callback payload once');
        is_deeply(
            \@messages,
            [["[eventMacro] Callback Happenned, type: 'variable', name: 'foo', variable type: 'accessed_array', array index: '3', variable value: 'VALUE'\n", 'eventMacro', 3]],
            'enabled diagnostic keeps its original format and log domain'
        );
    };
}

1;
