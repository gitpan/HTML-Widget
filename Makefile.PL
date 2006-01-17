use inc::Module::Install;

name 'HTML-Widget';
all_from 'lib/HTML/Widget.pm';

requires 'perl' => '5.8.1';
requires 'HTML::Element';
requires 'Class::Accessor::Fast';
requires 'Class::Accessor::Chained::Fast';
requires 'Email::Valid';
requires 'Date::Calc';
requires 'Test::MockObject';
requires 'HTML::Scrubber';
requires 'Storable';

auto_install;
&WriteAll;
