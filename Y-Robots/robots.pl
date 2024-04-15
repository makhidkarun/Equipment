print<<EOINTRO;

Data Format: each line defines the attributes of one robot:
 - name or type
 - brain (O)rganic (S)emi-organic (P)ositronic (E)lectronic 
   - + rating: (D=) 1D (DD=) 2D (DDD=) 3D
 - senses (V)isual (H)earing (A)wareness (T)ouch (P)ercept (S)mell
   - extras: +T telescopic, +M microscopic, +R recorder
 - body has three parts:
   - optional: (va) VAgile (a) Agile 
   - optional: (L)ight (H)eavy 
   - (E)xoskeleton (X) Exterior shell (L) fluid (F)lexible skeleton 
     (B)ony skeleton
   - optional: (+s1) string (+s2) stronger
 - limb group 1
 - limb group 2
 - limb groups 3 and 4

   - Limb groups are of the format:
     - Number of limbs in the group (e.g. 1, 2, 3)
     - (XS)mall (SS)mall (S-) Small (M) standard (L)arge
     - +H arms with hands
     - +T arms with tentacles
     - +xG arms with dextrous graspers
     - +V arms with heavy-duty manipulators
     - +Pd arms with peds 
     - +F arms with fine detail control

 - antenna (S)small (A)anntennae
 - evironmental (H)ot (D) cold (R)ad (V)acc (P)ressure (W)aterproof
                (X) anti-corrode (E) shock
 - connector (L)ift base (Z)ero-G base
 - skin (S) metallic (P)seudo-bio (B)iological (B+H) self-healing
 - additions (M) ballistic tracker (S)atellite tracker (B)eacon tracker 
             (E) sonic emitter (F)loodlight (N)etworked (R)adio
 - basic UPP (Str Dex End Int Edu)
 - power (P) 1 day (7P) 7 day (HP) 1 day HD (7HP) 7 day HD (FP) fusion 
         (B)roadcast (X.C) Nutrient (N.CA) Nutrient and Air
 - size = (Str + Dex + End) x 12
 - kcr (optional)

EOINTRO

for (<DATA>)
{
   chomp;
   my ($type, $brain, $senses, $body, $LG1, $LG2, $LG34, $antenna, $a, $b, $c, $d, $upp, $power, $size, $kcr) = split /\s*,\s*/;

   my $upp1    = decodeUPP( $upp );
   my $brain1  = decodeBrain( $brain ) . " brain";
   my $senses1 = decodeSenses( $senses );
   my $body1   = decodeBody( $body );
   
   my @limbs1  = compress(decodeLimbs( $LG1 ), decodeLimbs( $LG2 ), decodeLimbs( $LG34 ), decodeAntenna( $antenna ));
   my $lastLimb = shift @limbs1;
   my $limbs1  = join ", ", @limbs1;
   $limbs1 .= " and " if $limbs1;
   $limbs1 .= $lastLimb;
   
   my $enhancement1 = decodeEnhancements( $a );
   my $baseplate1   = decodeConnectors( $b );
   my $skin1        = decodeSkin( $c );
   my $additions1   = decodeAdditions( $d );
   my $power1       = decodePower( $power );

   $kcr = '???' unless $kcr;
   my $cost         = 'KCr' . $kcr;
   
   my $skills = '';
   my $enhancement2 = $enhancement1;
   $enhancement1 = ", $enhancement1, " if $enhancement1 =~ /\w/;
   
   my $limbs2 = $limbs1;
   $limbs2 .= "\nBaseplate:    $baseplate1" if $baseplate1 =~ /\w/;
      
   my $description;

   $description = "The $type robot has a $brain1.  "
                . "Its body is a $body1 with $limbs1, "
                . "and has $skin1.  "
                . "It is powered by $power1";
   $description .= ", and is connected to a $baseplate1" if $baseplate1 =~ /\w/;
   $description .= ".  ";
   $description .= "Additions: $additions1.  " if $additions1 =~ /\w/;

   print <<EORDC;
file:         Y-$type-$size.yml.txt
Label:        $type robot, Size $size, UPP ${upp}R$enhancement1 $cost
UPP:          ${upp}R
Senses:       $senses1
Body:         $body1
Limbs:        $limbs2
Skin:         $skin1
Enhancements: $enhancement2
Additions:    $additions1
Brain:        $brain1
Power:        $power1
Skills:       $skills
Description:  $description

EORDC

   print "\n\n";

=pod
   print "suggested filename: Y-$type-$size.yml.txt";

   print "$type, Size $size, UPP ${upp1}R\n";
   print " Brain: $brain1\n";
   print " Senses: $senses1\n";
   print " Body: $body1\n";
   print " Limbs: Arms 1(", decodeLimbs( $LG1 ), "), Arms 2(", decodeLimbs($LG2), ") Legs(", decodeLimbs( $LG34 ), ") ", decodeAntenna( $antenna ),  "\n";
   print " Enhancements: ", decodeEnhancements($a), "\n";
   print " Connectors: ", decodeConnectors($b), "\n";
   print " Skin: ", decodeSkin($c), "\n";
   print " Additions: ", decodeAdditions($d), "\n";
   print " Power: ", decodePower( $power ), "\n";

   print "\n\n";
=cut   
}

sub compress
{
   my @list = @_;
   my @out  = ();
   for (@list)
   {
      push @out, $_ if $_;
   }
   return @out;
}

sub decodeSenses
{
   my $s = shift;
   my ($t, $extra) = split /\+/, $s;
   my @out = ();
   
   push @out, 'visual'     if $t =~ /V/;
   push @out, 'auditory'   if $t =~ /H/;
   push @out, 'awareness'  if $t =~ /A/;
   push @out, 'touch'      if $t =~ /T/;
   push @out, 'perception' if $t =~ /P/;
   push @out, 'olfactory'  if $t =~ /S/;
   
   my $out = join ', ', @out;
   $out .= " senses";
   
   my @out2 = ();
   push @out2, "telescopic"  if $extra =~ /T/;
   push @out2, "microscopic" if $extra =~ /M/;
   push @out2, "recorder"    if $extra =~ /R/;
#   push @out2, "F" if $extra =~ /F/;

   $out .= ', ' . join(',', @out2) . ' options' if @out2;

   return "\u$out";
}

sub decodeUPP
{
   my $u = shift;
   return $u . 'R';
}

sub decodeEnhancements
{
   my $b = shift;
   $b =~ s/-//;
   $b =~ s/=.*//; # volume
   
   my @out;
   push @out, "Hot Env" if $b =~ /H/;
   push @out, "Cold Env" if $b =~ /D/;
   push @out, "Rad" if $b =~ /R/;
   push @out, "Vacc" if $b =~ /V/;
   push @out, "Pressure" if $b =~ /P/;
   push @out, "Waterproof" if $b =~ /W/;
   push @out, "Anti-Corrosion" if $b =~ /X/;
   push @out, "Shock" if $b =~ /E/;
   return join ', ', @out;
}

sub decodeConnectors
{
   my $b = shift;
   $b =~ s/L/Lift Baseplate/;
   $b =~ s/Z/Zero-G Baseplate/;
   $b =~ s/=.*//; # volume
   $b =~ s/-//;
   
   return $b;
}
sub decodeSkin
{
   my $b = shift;
   $b =~ s/-//;
   $b =~ s/=.*//; # volume
   $b = "No skin" unless $b =~ /\w/;
   $b =~ s/S/basic metallic skin/;
   $b =~ s/P/pseudo-bio skin/;
   $b =~ s/B\+H/self-healing biological skin/;
   $b =~ s/B/biological skin/;
   
   return $b;
}
sub decodeAdditions
{
   my $b = shift;
   $b =~ s/-//;
   $b =~ s/=.*//; # volume
   
   my @out = ();
   push @out, 'Ballistic Tracking' if $b =~ /M/;
   push @out, 'Satellite Tracking' if $b =~ /S/;
   push @out, 'Beacon Tracking'    if $b =~ /B/;
   push @out, 'Sonic Emitter'      if $b =~ /E/;
   push @out, 'Floodlight'         if $b =~ /F/;
   push @out, 'Networking'         if $b =~ /N/;
   push @out, 'Radio Transceiver'  if $b =~ /R/;
   return join ', ', @out;
}
sub decodePower
{
   my $b = shift;
   $b =~ s/^P=/1-Day PowerCell=/;
   $b =~ s/7P/7-Day PowerCell/;
   $b =~ s/HP/1-Day HD PowerCell/;
   $b =~ s/7HP/7-Day HD PowerCell/;

   $b =~ s/FP/Fusion\+/;
   $b =~ s/B/Broadcast Power/;
   $b =~ s/X.C/Anaerobic Nutrient and Canister/;
   $b =~ s/N.CA/Nutrient and Air Canister/;

   $b =~ s/=.*//; # volume
   
   return $b;
}

sub decodeBrain
{
   my $b = shift;
   $b =~ s/O/Organic /;
   $b =~ s/S/Semi-Organic /;
   $b =~ s/P/Positronic /;
   $b =~ s/E/Electronic /;
   $b =~ s/ D=.*/ (1D)/;
   $b =~ s/ DD=.*/ (2D)/;
   $b =~ s/ DDD=.*/ (3D)/;
   return $b;
}

sub decodeBody
{
   my $b = shift;
   $b =~ s/^va([A-Z])/VAgile $1/;
   $b =~ s/^a([A-Z])/Agile $1/;
   $b =~ s/L([EXLBF])/Light $1/;
   $b =~ s/H([EXLBF])/Heavy $1/;

   $b =~ s/E(\W)/Exoskeleton$1/;
   $b =~ s/X(\W)/Exterior Shell$1/;
   $b =~ s/L(\W)/Fluid Interior$1/;
   $b =~ s/F(\W)/Flexible Interior Skeleton$1/;
   $b =~ s/B(\W)/Bony Interior Skeleton$1/;

   $b =~ s/(.*)\+s1/Strong $1/;
   $b =~ s/(.*)\+s2/Stronger $1/;
   
   $b =~ s/=.*//; # volume
   
   return $b;
}

sub decodeLimbs
{
   my $b = shift;
   $b =~ s/-//;
   
   #$b =~ s/SL/SLarge/;
   $b =~ s/XS/ XSmall/;
   $b =~ s/SS/ SSmall/;
   $b =~ s/S=/ Small=/;
   $b =~ s/M/ Standard/;
   $b =~ s/L/ Large/;
   $b =~ s/-//g;
   
   $b =~ s/=/ Legs=/ unless $b =~ /\+/; # only arms have manipulators
   
   $b =~ s/\+H/ Arms with Hands/;
   $b =~ s/\+T/ Arms with Tentacles/;
   $b =~ s/\+xG/ Arms with Dextrous Graspers/;
   $b =~ s/\+V/ Arms with Heavy-Duty maniplators/;
   $b =~ s/\+Pd/ Arms with Ped Options/;
   $b =~ s/\+F/ Arms with Fine Detail control/;
   
   $b =~ s/=.*//; # volume
   
   return $b;
}

sub decodeAntenna
{
   my $b = shift;
   $b =~ s/S/Small /;
   $b =~ s/A/Antennae/;
   $b =~ s/-//;
   $b =~ s/=.*//; # volume
   
   return $b;
}

__DATA__
T-35 Cargo Handler , PD=2,  V+RF,      HE+s1=19,   3L+T=27, -,        -,     -,    -,         L=30, -,     -,     L7742, FP=20,  120
HeNRY Remote Guard  , EDD=2, VH+TR,     LX=8,       3XS+T=6, -,        -,     -,    E=1,       L=30, -,     N=1,   48882, 7P=12,  60
Belter        , PDD=2, V+TMR,     HE+s1=19,   3L+V=30, -,        -,     -,    HDRV=4,    Z=4,  -,     BNR=3, F8884, FP=20,  84
Life Support Maintenance  , ED=1,  VHS,       HX+s1=16,   2L+H=18, -,        2M=18, -,    RVWX=4,    -,    -,     -,     F8844, B=4,    60
Attack        , SD=2,  VHAS,      vaHE+s1=21, 2M+Pd,   2L+Pd=36, 2L=24, -,    RW=2,      -,    B+H=1, SN=2,  FE884, X+C=11, 96
Guardian      , PDD=2, VHAS,      X=10,       2SS+R=12,-,        -,     -,    EV=2,      L=30, -,     RN=2,  88884, 7P=12,  72
Infantry      , ODD=3, VHAP,      B=12,       2L+H=14, -,        2M=18, SA=4, HDRVPWX=7, -,    S2=3,  SR=2,  8C886, X+C=11, 84
Sentinel      , PD=2,  VHA,       HE+s2=20,   6L+T=54, -,        -,     -,    RV=2,      L=30, -,     FN=2,  SCC44, FP=20,  132 
Recon         , SDD=3, VHAP+R,    aF=11,      3S+xG=15,-,        4S=24, -,    WX=2,      -,    S+H=1, SN=2,  48C82, X+C=11, 72
Advisor       , ODD=3, VH+R,      LB=8,       2S+H=10, -,        2S=12, -,    -,         -,    P=1,   N=1,   48484, N+CA=12, 48
Repair        , ED=2,  VHST,      HF+s1=15,   1M+F,    2M+V=17,  3L=36, -,    HDRVPWX=7, -,    -,     -,     F8846, HP=7,    84
Service       , ODD=3, VHST,      B=12,       2M+H=14, -,        2M=18, -,    -,         -,    P=1,   -,     88482, N+CA=12, 60
Doctor        , SDD=3, VTS+R,     F=10,       2M+H=14, S+F=5,    3S=18, -,    HDR=3,     -,    P=1,   N=1,   4C886, X+C=11,  72
Bearer        , ED=1,  VHT,       E=16,       M+T=7,   -,        -,     -,    HDRVWX=6,  L=30, -,     -,     88842, 7P=12,   72
Clerk         , SD=2,  VH+R,      LB=8,       2S+H=10, -,        2S=12, -,    -,         -,    P=1,   N=1,   48444, B=4,     48
Driver        , SD=2,  VHT+R,     LE=12,      3M+H=18, -,        2M=18, -,    RV=2,      -,    -,     NRMB=4,84846, P=4,     60
Flyer         , SD=2,  VHT+R,     LE=12,      3M+H=18, -,        2M=18, -,    RV=2,      -,    -,     NRMB=4,48846, P=4,     60
Researcher    , ODD=3, VHTSP+R,   L=8,        2M+F=14, 2M+H=14,  2M=18, -,    HDRVPWX=7, -,    P=1,   NR=2,  88886, P=4,     72
Forensic      , SDD=3, VHTS+R,    LF=6,       M+F=7,   M+H=7,    2SS=16,-,    RW=2,      -,    P=1,   NR=2,  48486, P=4,     48
Security Drone, ED=1,  VH+TR,     HX=15,      2L+V=20, -,        -,     -,    RVW=3,     L=30, S=1,   SN=2,  CC844, FP=20,   96
Agricultural  , ED=1,  VTS+MR,    aHX+s1,     2XS+F,   2M+xG,    2L+T,  A,    WXE,       L,    S,     EFNR,  AAA44, FP,      360, 350
Cargo Handler , ED=1,  VH,        HE+s2,      4L+V,    -,        -,     A,    RV,        L,    S,     EFNR,  AAA44, HD,      360, 200
