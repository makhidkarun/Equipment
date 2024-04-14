use YAML;

my $yaml = YAML::LoadFile( "Pistol Snub Std-7.yml.txt");

print $yaml->{ 'description' };