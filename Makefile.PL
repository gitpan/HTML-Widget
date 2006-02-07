use inc::Module::Install;

name 'HTML-Widget';
all_from 'lib/HTML/Widget.pm';

requires 'perl' => '5.8.1';
requires 'HTML::Element';
requires 'Class::Accessor::Fast';
requires 'Class::Accessor::Chained::Fast';
requires 'HTML::Scrubber';
requires 'Storable';

build_requires 'Test::MockObject';

recommends 'Email::Valid';
recommends 'Date::Calc';

auto_install;
&WriteAll;
