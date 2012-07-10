#!/usr/bin/perl -w

# USAGE:
#
# /RSAY [-(j|r)] <text>
#  - same as /say, but outputs a coloured text
#
# /RME [-(j|r)] <text>
#  - same as /me, but outputs a coloured text
#
# /RTOPIC <text>
#  - same as /topic, but outputs a coloured text :)
#
# /RKICK <nick> [reason]
#  - kicks nick from the current channel with coloured reason
#
# /HEARTSAY <text>
#  - output you text with colored hearts before and after
#
# /KITTY <text>
#  - output a kitty in 3 lines with your text on the right of it

# Written by Jakub Jankowski <shasta@atn.pl>
# for Irssi 0.7.98.4 and newer

# Enhanced by Simon "Quark" Bouteille
# And Jeremy "Aniem" Buet

use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.4";
%IRSSI = (
    authors     => 'Jakub Jankowski',
    contact     => 'shasta@atn.pl',
    name        => 'rainbow',
    description => 'Prints colored text. Rather simple than sophisticated.',
    license     => 'GNU GPLv2 or later',
    url         => 'http://irssi.atn.pl/',
);

use Irssi;
use Irssi::Irc;
use utf8;
Irssi::theme_register([ 
    'rainbow_cmd_syntax',		'%_$0:%_ $1, usage: $2',
]);
# colors list
my @colors = ('2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16');
my $last = 255;
my $last2 = 255;

sub kitty {
    my $usage = "/kitty [-[0-15]] [-(j|r|R)] <text>";
	my ($arguments, $server, $dest) = @_;
    my ($cmd, $string);
    my $mode = 15;
    my $kittycolor = 11;
    my $chat1 = '(\___/) ';
    my $chat2 = "(=*.*=) ";
    my $chat3 = '(")_(") ';
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}
    my @foo = split(/ /, $arguments);
	while ($_ = shift(@foo)){
		/^-(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15)$/ and $kittycolor = $_, next;
        /^-(j|r|R)$/ and $mode = $_, next;
		/^-/ and Irssi::printformat(MSGLEVEL_CRAP, "rainbow_cmd_syntax", "kitty", "Unknown argument: $_", $usage), return;
		$string = ($#foo < 0) ? $_ : $_ . " " . join(" ", @foo);
		last;
	};
    
	return unless $dest;
    if($kittycolor < 0){$kittycolor = abs($kittycolor)}
    my $c = int(length($string)/3);
    while (!(substr($string, $c, 1) eq ' ') && $c < int(length($string))) {$c++};
    my $d = int((2/3)*length($string));
    while (!(substr($string, $d, 1) eq ' ') && $d < int(length($string))) {$d++};
    if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
        my $newstr = make_colors($kittycolor,$chat1);
        my $string1 = substr($string, 0, $c);
        $newstr .= make_colors($mode,$string1);
        $dest->command("/msg " . $dest->{name} . " " . $newstr);
        $newstr = make_colors($kittycolor,$chat2);
        $string1 = substr($string, $c+1, $d-$c);
        $newstr .= make_colors($mode,$string1);
        $dest->command("/msg " . $dest->{name} . " " . $newstr);
        $newstr = make_colors($kittycolor,$chat3);
        $string1 = substr($string, $d+1);
        $newstr .= make_colors($mode,$string1);
        $dest->command("/msg " . $dest->{name} . " " . $newstr);
    }
}

# str make_colors($string)
# returns random-coloured string
sub make_colors {
	my ($mode,$string) = @_;
	my $newstr = "";
    my $max = @colors-1;
    my $color = 0;

	utf8::decode($string);

    if($mode =~ /j/){
        for (my $c = 0; $c < length($string); $c++) {
            my $char = substr($string, $c, 1);
            if ($char eq ' ') {
                $newstr .= $char;
                next;
            }
            $newstr .= "\003";
            $newstr .= sprintf("%02d", $colors[$color]);
            $newstr .= $char;
            if($color < $max){$color++}
            else{$color = 0}
        }
    }elsif($mode =~ /r/){
        $color = $max;
        for (my $c = 0; $c < length($string); $c++) {
            my $char = substr($string, $c, 1);
            if ($char eq ' ') {
                $newstr .= $char;
                next;
            }
            $newstr .= "\003";
            $newstr .= sprintf("%02d", $colors[$color]);
            $newstr .= $char;
            if($color > 0){$color--}
            else{$color = $max}
        }
    }elsif($mode =~ /R/){
        for (my $c = 0; $c < length($string); $c++) {
            my $char = substr($string, $c, 1);
            if ($char eq ' ') {
                $newstr .= $char;
                next;
            }
            $color = int(rand(scalar(@colors)));
            while (($color == $last) || ($color == $last2)) {
                $color = int(rand(scalar(@colors)));
            };
            $last2 = $last;
            $last = $color;
            $newstr .= "\003";
            $newstr .= sprintf("%02d", $colors[$color]);
            $newstr .= $char;
        }
    }else{
        $color = $mode;
        for (my $c = 0; $c < length($string); $c++) {
            my $char = substr($string, $c, 1);
            if ($char eq ' ') {
                $newstr .= $char;
                next;
            }
            $newstr .= "\003";
            $newstr .= sprintf("%02d", $colors[$color]);
            $newstr .= $char;
        }   
    }

	return $newstr;
}

# void rsay($text, $server, $destination)
# handles /rsay
sub rsay {
    my $usage = "/rsay [-(j|r|R)] <text>";
	my ($arguments, $server, $dest) = @_;
    my ($cmd, $text);
    my $mode = '-R';
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}
    
    my @foo = split(/ /, $arguments);
	while ($_ = shift(@foo))
	{
		/^-(r|j|R)$/ and $mode = $_, next;
		/^-/ and Irssi::printformat(MSGLEVEL_CRAP, "rainbow_cmd_syntax", "rsay", "Unknown argument: $_", $usage), return;
		$text = ($#foo < 0) ? $_ : $_ . " " . join(" ", @foo);
		last;
	};

	unless (length($text)) {
		Irssi::printformat(MSGLEVEL_CRAP, "rainbow_cmd_syntax", "rsay", "Missing arguments", $usage);
		return;
	};

	return unless $dest;

	if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
		$dest->command("/msg " . $dest->{name} . " " . make_colors($mode,$text));
	}
}

# void rme($text, $server, $destination)
# handles /rme
sub rme {
    my $usage = "/rme [-(j|r|R)] <text>";
	my ($arguments, $server, $dest) = @_;
    my ($cmd, $text);
    my $mode = '-R';
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}
    
    my @foo = split(/ /, $arguments);
	while ($_ = shift(@foo))
	{
		/^-(r|j|R)$/ and $mode = $_, next;
		/^-/ and Irssi::printformat(MSGLEVEL_CRAP, "rainbow_cmd_syntax", "rsay", "Unknown argument: $_", $usage), return;
		$text = ($#foo < 0) ? $_ : $_ . " " . join(" ", @foo);
		last;
	};

	unless (length($text)) {
		Irssi::printformat(MSGLEVEL_CRAP, "rainbow_cmd_syntax", "rsay", "Missing arguments", $usage);
		return;
	};

	return unless $dest;

	if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
		$dest->command("/me " . make_colors($mode,$text));
	}
}


# void rtopic($text, $server, $destination)
# handles /rtopic
sub rtopic {
	my ($text, $server, $dest) = @_;
    my $mode = '-R';

	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}

	if ($dest && $dest->{type} eq "CHANNEL") {
		$dest->command("/topic " . make_colors($mode,$text));
	}
}

# void rkick($text, $server, $destination)
# handles /rkick
sub rkick {
	my ($text, $server, $dest) = @_;
    my $mode = '-R';
    
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}

	if ($dest && $dest->{type} eq "CHANNEL") {
		my ($nick, $reason) = split(/ +/, $text, 2);
		return unless $nick;
		$reason = "Irssi power!" if ($reason =~ /^[\ ]*$/);
		$dest->command("/kick " . $nick . " " . make_colors($mode,$reason));
	}
}

sub heartsay {
	my ($text, $server, $dest) = @_;
    my $mode = '-R';
    my $string = "\0032♥ \0033♥ \0034♥ \0035♥ \0036♥ \0037♥ \0038♥ \0039♥ \00310♥ \00311♥ \00312♥ \00313♥ \00314♥ \00315♥ \00316♥ ";
    $string .= make_colors($mode,$text);
    $string .= " \00316♥ \00315♥ \00314♥ \00313♥ \00312♥ \00311♥ \00310♥ \0039♥ \0038♥ \0037♥ \0036♥ \0035♥ \0034♥ \0033♥ \0032♥";

	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}

	if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
		$dest->command("/msg " . $dest->{name} . " " . $string);
	}	
}

sub gros_coeur{
	my (@arguments) = @_;
	my $l = @arguments;
	my @lines = ("", "", "", "", "");
	if($l != 7){
		return
	}
	else{
		my $color = @arguments[$l-1];
		my $char = @arguments[$l-2];
		my @lines = ("", "", "", "", "");
		for(my $n = 0; $n < $l-2; $n++){
			$lines[$n] = $arguments[$n];
		}
		$lines[0] .= make_colors($color,' _ _  ');
		$lines[1] .= make_colors($color,'/ V \\ ');
		$lines[2] .= make_colors($color,'\\ '); 
		$lines[2] .= make_colors($color,$char);
		$lines[2] .= make_colors($color,' / ');
		$lines[3] .= make_colors($color,' \\ /  ');
		$lines[4] .= make_colors($color,'  V   ');
		return @lines;
	}
}

sub srheartsay {
	my $usage = "/srheartsay [-(j|r|R)] <text>";
    my ($arguments, $server, $dest) = @_;
	my $text ="";
	my $mode = undef;
	my @line = ("", "", "", "", "");
	my $number = @line;
	my $last = 255;
	my $last2 = 255;
	my $color = 0;
	my $max = @colors-1;

	utf8::decode($text);

	my @foo = split(/ /, $arguments);
	while ($_ = shift(@foo))
	{
		/^-(r|j|R)$/ and $mode = $_, next;
		/^-/ and Irssi::printformat(MSGLEVEL_CRAP, "rainbow_cmd_syntax", "rsay", "Unknown argument: $_", $usage), return;
		$text = ($#foo < 0) ? $_ : $_ . " " . join(" ", @foo);
		last;
	};
	
	if($mode =~ /j/){
        for (my $c = 0; $c < length($text); $c++) {
			my $char = substr($text, $c, 1);
            @line = gros_coeur(@line,$char,$color);
            if($color < $max){$color++}
            else{$color = 0}
        }
    }elsif($mode =~ /r/){
        $color = $max;
        for (my $c = 0; $c < length($text); $c++) {
			my $char = substr($text, $c, 1);
            @line = gros_coeur(@line,$char,$color);
            if($color > 0){$color--}
            else{$color = $max}
        }
    }else{
        for (my $c = 0; $c < length($text); $c++) {
			my $char = substr($text, $c, 1);
            $color = int(rand(scalar(@colors)));
            while (($color == $last) || ($color == $last2)) {
                $color = int(rand(scalar(@colors)));
            };
            $last2 = $last;
            $last = $color;
            @line = gros_coeur(@line,$char,$color);
        }
	}

	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
		return;
	}

	if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
		for(my $n = 0; $n < $number; $n++){
			$dest->command("/msg " . $dest->{name} . " " . $line[$n]);
		}
	}	

}

Irssi::command_bind("rsay", "rsay");
Irssi::command_bind("rtopic", "rtopic");
Irssi::command_bind("rme", "rme");
Irssi::command_bind("rkick", "rkick");
Irssi::command_bind("heartsay", "heartsay");
Irssi::command_bind("srheartsay", "srheartsay");
Irssi::command_bind("kitty", "kitty");

# changes:
#
# 31.05.2012: /kitty and /heartsay added
# 25.01.2002: Initial release (v1.0)
# 26.01.2002: /rtopic added (v1.1)
# 29.01.2002: /rsay works with dcc chats now (v1.2)
# 02.02.2002: make_colors() doesn't assign any color to spaces (v1.3)
# 23.02.2002: /rkick added
