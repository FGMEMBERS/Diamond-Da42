#!/usr/bin/perl -w

# PerlMagick of ImageMagick is necessary

use strict;
use Image::Magick;

my $imageFormat = "png";
my $originalMapsDir = "../../../../Atlas/10";
my $FGHOME = "../../../../SceneryTerraSync";
my $OS = (exists $ENV{OS}) ? $ENV{OS} : "";
if (exists $ENV{FGHOME}) {
    $FGHOME = $ENV{FGHOME};
}
else {
    if ($OS eq 'Windows_NT') {
        $FGHOME = $ENV{APPDATA}."/flightgear.org";
    }
    else {
        $FGHOME = $ENV{HOME}."/.fgfs";
    }
}
my @originalTiles = ();
if ($OS eq 'Windows_NT') {
    $originalMapsDir =~ s:\\:/:g;
    @originalTiles = glob("\"$originalMapsDir/*.$imageFormat\"");
}
else {
    @originalTiles = glob("$originalMapsDir/*.$imageFormat");
}

my $maps = "$FGHOME/zkv1000/maps";

if (! -d $maps) {
    if ($OS eq 'Windows_NT') {
        system("mkdir \"".$maps."/terrain\"");
    }
    else {
        system("mkdir -p $maps/terrain");
    }
}

my $error = 0;
my $map = Image::Magick->new;
my $element = Image::Magick->new;

sub getNeighbours ($) {
    my $t = shift;
    my ($e, $ne, $n, $nw, $w, $sw, $s, $se);
    $t =~ m/(e|w)([0-9]{3})(n|s)([0-9]{2})/;
    my @tilename = ($1, $2, $3, $4);
    if ($tilename[0] eq 'e') {
        if ($tilename[1] == 179) {
            $w = "e178";
            $e = "w180";
        }
        elsif ($tilename[1] == 0) {
            $w = "w001";
            $e = "e001";
        }
        else {
            $w = sprintf("e%03i", $tilename[1] - 1);
            $e = sprintf("e%03i", $tilename[1] + 1);
        }
    }
    else {
        if ($tilename[1] == 180) {
            $e = "e179";
            $w = "w179";
        }
        elsif ($tilename[1] == 1) {
            $w = "w002";
            $e = "e000";
        }
        else {
            $w = sprintf("w%03i", $tilename[1] + 1);
            $e = sprintf("w%03i", $tilename[1] - 1);
        }
    }

    if ($tilename[2] eq 'n') {
        if ($tilename[3] == 0) {
            $n = "n01";
            $s = "s01";
        }
        else {
            $n = sprintf("n%02i", $tilename[3] + 1);
            $s = sprintf("n%02i", $tilename[3] - 1);
        }
    }
    else {
        if ($tilename[3] == 1) {
            $n = "n00";
            $s = "s02";
        }
        else {
            $n = sprintf("s%02i", $tilename[3] - 1);
            $s = sprintf("s%02i", $tilename[3] + 1);
        }
    }
    $ne = $e.$n.".$imageFormat";
    $nw = $w.$n.".$imageFormat";
    $se = $e.$s.".$imageFormat";
    $sw = $w.$s.".$imageFormat";
    $n = $tilename[0].$tilename[1].$n.".$imageFormat";
    $s = $tilename[0].$tilename[1].$s.".$imageFormat";
    $w .= $tilename[2].$tilename[3].".$imageFormat";
    $e .= $tilename[2].$tilename[3].".$imageFormat";
    return ($n, $ne, $e, $se, $s, $sw, $w, $nw);
}

sub addToMap ($$) {
    my ($t, $xoffset, $yoffset) = (shift, shift, shift);
    -e "$originalMapsDir/$t" or return;

    @$element = ();

    $error = $element->Read("$originalMapsDir/$t");
    die $error if $error;

    $element->Scale(geometry => '1024x1024!');

    $map->Composite(
        image=>$element->[0],
        geometry=>sprintf("%+i%+i", $xoffset, $yoffset)
    );
}

my $begin = time;


for (my $i = 0; $i <= $#originalTiles; $i++) {
    @$map = ();

    my @temp = split(/\//, $originalTiles[$i]);
    my $tile = $temp[$#temp];
    if (-e "$maps/terrain/$tile") {
        $error = $map->Read("$maps/terrain/$tile");
        die $error if $error;
    }
    else {
        $map = Image::Magick->new;
        $map->Set(size=>'1536x1536');
        $map->ReadImage('xc:black');
    }
    
    my @neighbourhood = &getNeighbours($tile);
    &addToMap($tile,             256,      256);
    &addToMap($neighbourhood[0], 256,      256-1024); #n
    &addToMap($neighbourhood[1], 256+1024, 256-1024); #ne
    &addToMap($neighbourhood[2], 256+1024, 256);      #e
    &addToMap($neighbourhood[3], 256+1024, 256+1024); #se
    &addToMap($neighbourhood[4], 256,      256+1024); #s
    &addToMap($neighbourhood[5], 256-1024, 256+1024); #sw
    &addToMap($neighbourhood[6], 256-1024, 256);      #w
    &addToMap($neighbourhood[7], 256-1024, 256-1024); #nw

    $map->Scale(geometry => '1024x1024!');

    $map->Write(filename => "$maps/terrain/$tile");
    
    my @eta = localtime(((time - $begin) / ($i + 1)) * ($#originalTiles - $i) - 3600);
    printf("%i / %i, ETA: %ih%02im%02is\n", $i + 1, $#originalTiles + 1, $eta[2], $eta[1], $eta[0]);
}
