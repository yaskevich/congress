#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010;
binmode STDOUT, ':encoding(UTF-8)';
use Mojolicious::Lite;
use DBI;
use Data::Dumper;

my $dbh = DBI->connect("dbi:SQLite:crm.db","","", {sqlite_unicode => 1}) or die "Could not connect";

my $txt = <<END;
Javorska Galina (Украіна)
Gjurkova Aleksandra (Македонія)
Pencev Vladimir (Балгарыя)
Rudenko Elena (Беларусь)

END
use open qw(:std :utf8);
	my $sth = eval { $dbh->prepare("SELECT id, be, cyr FROM countries WHERE be NOT NULL") } || return undef;
	$sth->execute;
	my $ref = $sth->fetchall_arrayref({});
	
	$sth = eval { $dbh->prepare("SELECT * from persons") } || return undef;
	$sth->execute;
	my $pref = $sth->fetchall_hashref('here_name');
	$sth->execute;
	my $pref_id = $sth->fetchall_hashref('id');
	# say Dumper ($pref);
	# exit;

open FILE, "XV_MSS_fixed_by_philology_by(doc)2.txt" or die "Couldn't open file: $!";

open LOG, ">log.txt" or die "Couldn't open file: $!";

# binmode FILE, ":utf8";
 my $a = 0;
 my $num = 0;
 my $mode = 0;
 my @guys = (); # $num. $id, $country_id
 my $guys_num = 0;
 my $s_title = '';
 my $lvl = 0;
 my $s_code = 0;
 my $s_code_desc = '';
 my $s_place;
 my $s_time;
 my $s_day;
 my $table_mode = 0;
 # SELECT P.country_id, COUNT(P.country_id) as people,C.[be] FROM persons AS P JOIN countries AS C ON P.country_id=C.id group by country_id order by people DESC;
foreach my $line (<FILE>){		
		next if $line =~ /^\s+$/;
		chomp $line;
		$line =~ s/\[A.Y.\d+\]//g; 
		
		 if ($line eq '4.1. Круглыя сталы'){
			$table_mode =1;
			next;
		 }
		
		$mode = 1 if $line eq 'С Е К Ц Ы І';
		$mode = 0 if $line eq '4.3. Пасяджэнні камісій, акрэдытаваных пры МКС';
		
		
		
		
		# say "yes" if $line eq '4.3. Пасяджэнні камісій, акрэдытаваных пры МКС';
		# next;
		next unless $mode;
		# say "yes!";
		# exit;
		$line =~ s/\s+/ /g;
		$line =~ s/\s+$//;
		
		next unless length($line);
		
		if ($table_mode){
			# print STDERR '.';
			if ($line=~ /^(\d\.\d+\.\d+)\.(.*)/){
				# say STDERR $1;
				$s_code = $1;
				$lvl = 0;
				$s_code_desc = $2; # PSUH TO DB!!!
			
			say LOG "$s_code| $s_place {$s_day} $s_time - TITLE:".$s_code_desc;
			event ($s_code, $s_code_desc, $s_time,  $s_day, $s_place, 4, 0, $lvl);
			}
			# say "LINE[$line]"
		} 
		
		if ($guys_num){
			my $next = 0;
			my $topic = 'NOTOPIC';
			if ($line =~ /^\d+\.$/ or $line =~ /\:$/ or $line =~ /^час\:/ or $line =~/^\d+\.\d+\./ ) {
				# guy without a entitled paper
				# post a paper unnamed
				say "PAPER $guys_num :: NO TITLE";
			} else { 
				say "PAPER $guys_num :: $line";
				$line =~ s/^\s+|\s+$//g;
				$next = 1;
				$topic = $line;
				# post the paper and next
				
			}
			say LOG "$s_code| $s_place {$s_day} $s_time - PAPER:$guys_num PERSONS[".scalar(@guys)."][ID: ".join("  ", @guys)."] TOPIC: ".$topic;
			++$lvl;
			event ($guys_num, $topic, $s_time,  $s_day, $s_place, 3, $s_code, $lvl);
			
			
			### TIE WITH PERSon
			foreach my $x (@guys){
				timetable ($guys_num, $x, 1);
			}
			
			
			$guys_num = 0;
			undef (@guys);
			next if $next;
			
		}
		
		# say "LINE {$line}";
		if ($line =~ /^пасяджэнне\s+(\d.*?)\s*$/){ # before or after time and place!!! # 4.2.10. Ценности в...
			say "code $1";
			$s_code = $1;
			$lvl = 0;
		} elsif ($line =~ /^час\:\s+(\d\d)\s+жніўня\,\s+(\d.*)\s*$/){ # час: 24 жніўня, 11.30 – 13.00
			say "date $1 time $2";
			$s_time = $2;
			$s_day = $1;
		} elsif ($line =~ /^месца\:\s+(.*)\s*$/){ # месца: аўдыторыя V		
			say "place $1";
			$s_place = $1;
			unless ($s_place =~ /^аўдыторыя\s(\w+)$/){
				say STDERR $s_place;
			} else {
				$s_place = $1;
			}
		} elsif ($line =~ /^Старшынства:\s+(.*)\s*$/){ # месца: аўдыторыя V		
			# say "place $1";
			event ($s_code, '', $s_time,  $s_day, $s_place, 2, 0, $lvl);
			my @ids = comma_sep($1, $line, '**');
			foreach my $x (@ids){
					# say "** $x $pref_id->{$x}->{'here_name'}" if defined $x and exists $pref_id->{$x}->{'here_name'};
					
					say LOG "$s_code| $s_place {$s_day} $s_time - HEAD[".scalar(@ids)."][ID: ".join("  ", @ids)."]";
					timetable ($s_code, $x, 2);
			}
		} elsif ($line  =~ /^(Сумадэратар|Мадэратар):\s+(.*)$/){
				my $name  = $2; # Колер Гун-Брит (Германия),  Навуменка Павел (Беларусь)
				# say "# $line";
				$name =~ s/\s+\(.*?\)$//;
				 # say STDERR "$line {$name}" unless $name;
				 my @ids = comma_sep($name, $line, '#');
				  foreach my $x (@ids){
					 # say "## $x $pref_id->{$x}->{'here_name'}" if defined $x and exists $pref_id->{$x}->{'here_name'};
					 say LOG "$s_code| $s_place {$s_day} $s_time - MOD[".scalar(@ids)."][ID: ".join("  ", @ids)."]";
					 timetable ($s_code, $x, 3);
					 say STDERR "MOD ERR [$name]" unless $x;
				 } 
					 # say STDERR "MOD ERR [$name]".join("  ", @ids);
			}
		
		elsif ($line =~ /^(\d+)\.\s*$/){
			$num = $1;
		} # elsif ($num){
			elsif ($line  =~ /^(.*?)\s+\((.*?)\)$/ and $num){ # name processing #name (country)
			# say "{$line}";
			
			my $cntry = $2;
			my ($c_id, $cyr) = country_info($cntry);
				# say "No country ID for |$cntry| [$line]" unless $c_id;
			# } else {
				# # say "OOO $line";
				# # say "[$num] $pref->{$line}->{'id'} $line";
			# }
				$guys_num = $num;
				my $name = $1;
				# say "[$num] $pref->{$name}->{'id'} $line";
				my @ids = comma_sep($name, $line, '+');
				say '>>'.scalar(@ids).$line;
				foreach my $x (@ids){
					 if (exists $pref_id->{$x}->{'here_name'}) {
						say "PERSON $x $pref_id->{$x}->{'here_name'}";
						push @guys, $x;
					 } else {
						say STDERR "Smth wrong: $line";
					 }
						
				}
		
			
			$num = 0;
		} else {
			# say  $line;
		}		
		++$a;
		# exit if $a > 15;
}
close FILE;


  
  exit;
  sub event {
	
	my ($id, $title, $time, $date, $place, $type, $parent, $level) = @_;
	# say STDERR  scalar (@_) if scalar(@_) !=7; #$parent if $type == 3;
	# return;
	
	# 009.00 - 11.00
# 009.00 - 11.00
# 009.00 - 11.00
# 009.00 - 11.00

	if (substr($time, 0,1) !~ /0|1/) {
		$time = '0'.$time;
	}
	if (substr($time, 0, 2) eq '00'){
		say STDERR $time;
	}
	
	my @start_end = split(/\s+\-\s+/, $time);
	
	# say STDERR "$start_end[0] $start_end[1]";
	# exit;
	$sth = eval { $dbh->prepare('INSERT INTO global_topics (id, be, ru, event_date, event_place, event_type, parent_id, event_start, event_end, lvl) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)') } || return undef;
	$sth->execute($id, $title, $title, $date, $place, $type, $parent, $start_end[0], $start_end[1], $level);
  }
  sub timetable {
   # return;
	my ($event, $person_id, $role_id) = @_;
	$sth = eval { $dbh->prepare('INSERT INTO timetable (event_id, person_id, person_role) VALUES (?, ?, ?)') } || return undef;
	$sth->execute($event, $person_id, $role_id);
  }
sub comma_sep {
my ($name, $line, $pf) = @_;
my $indb;
my @ins = ();

if  (exists $pref->{$name}){
	# say STDERR "$pref->{$name}->{'id'} $line";
	push @ins, $pref->{$name}->{'id'};					
	return (@ins);
}
					
if ($name =~ /\,/){
	# say "!!!comma sep: $name";
	foreach my $subname (split(/\,\s/, $name)){
		if  (exists $pref->{$subname}){
			push @ins, $pref->{$subname}->{'id'};
		} else {
			$indb = check_cyr($subname);
			if ($indb){
				# say STDERR "$subname  -> $line";
			} else {
				my $swapped = $subname;
				$swapped =~ s/(\p{Lu}\p{Ll}+) (\p{Lu}\p{Ll}+)/$2 $1/;
				$indb = check_cyr($swapped);
				
				say STDERR $pf."ERROR: $subname" unless $indb;
				# say STDERR "LINE {$line}";
			}
			push @ins, $indb if $indb;
		}
	}
} else {
	my $indb = check_cyr($name);
	# say $indb ? "ok:".$indb :"N/A $line";
	# say Dumper ($pref_id);
	push @ins, $indb;
}
return (@ins);
}

sub check_cyr {
	my ($name2check) = @_;
	$name2check =~ s/\s+$//;
	foreach my $it (values %{$pref}){
		my ($v1, $v2) = ($it->{lname_cyr}.' '.$it->{fname_cyr}, $it->{fname_cyr}.' '.$it->{lname_cyr});
		# say Dumper ($it);
		return $it->{id} if ($name2check eq $v1 || $name2check eq $v2);		
	}
	foreach my $it (values %{$pref}){
		my ($v1, $v2) = ($it->{lname_lat}.' '.$it->{fname_lat}, $it->{fname_lat}.' '.$it->{lname_lat});
		# say Dumper ($it);
		return $it->{id} if ($name2check eq $v1 || $name2check eq $v2);		
	}
	foreach my $it (values %{$pref}){
		$name2check =~ /^(.*?)\s/;
		my $sur = $1;
		# say "ololo".$it->{id} if ($sur eq $it->{lname_cyr} || $sur eq $it->{lname_lat});		
		if (defined $sur){
			return $it->{id} if ($sur eq $it->{lname_cyr} || $sur eq $it->{lname_lat});		
		}
	}
	return 0;
}

  
 use Lingua::Translit;
my $tr = new Lingua::Translit("DIN 1460 RUS");

 my @items = split(/\n/, $txt);
 
  
  # exit;

	exit;
 foreach my $item (@items){
	 # $item =~ /\s*(\d\.\d)\.\s?(.*)/; 
	# say "[$1] {$2}";
	# my $sth = eval { $dbh->prepare('INSERT INTO global_topics ( id, be) VALUES (?, ?)') } || return undef;
	# $sth->execute($1, $2);
	# my $sth = eval { $dbh->prepare('UPDATE global_topics SET ru=? WHERE id=?') } || return undef;
	# $sth->execute($2, $1);
	$item  =~ /^(.*?)\s+\((.*?)\)$/;
	my $here_name = $1;
	my $cname = $2;
	# say $1 if $1;
	# exit;
	my ($id, $cyr) = country_info($cname);
	# say $here_name." - ".$cname if $cyr;
	# say "$id | $here_name " unless $cyr;
	my @chunks = split(/\s/, $here_name);
	# my @chunks = split(/\,\s/, $here_name);
	$here_name =~ s/\,//;
	# say Dumper (@chunks);
	# say $here_name;
	
	
	# next if $cyr;
	
	if (scalar(@chunks) == 2) {
		say "Sur {$chunks[0]} Name {$chunks[1]}";
		# next;
	} elsif (scalar(@chunks) > 2){
		# say "$here_name ($cname)";
		# next;
	}
	# next;
	my ($bname, $aname, $bname_cyr, $aname_cyr) = ($chunks[0], $chunks[1], $tr->translit_reverse($chunks[0]), $tr->translit_reverse($chunks[1]));
	
	# my ($bname, $aname, $bname_lat, $aname_lat) = ($chunks[0], $chunks[1].' '.$chunks[2], $tr->translit($chunks[0]), $tr->translit($chunks[1].' '.$chunks[2]));
	
	# next;
	# exit;
	# Sur $chunks[0] Name $chunks[1]";
	# say $tr->translit_reverse($here_name);
	# my $sth = eval { $dbh->prepare('INSERT INTO persons (here_name, bname, aname, country_id, cyr, lname_lat, fname_lat, lname_cyr, fname_cyr, lname_be, fname_be) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)') } || return undef;
	# $sth->execute($here_name, $bname, $aname, $id, 1, $bname_lat, $aname_lat, $bname, $aname, $bname, $aname);
	
	# Sur $chunks[0] Name $chunks[1]";
	# say $tr->translit_reverse($here_name);
	my $sth = eval { $dbh->prepare('INSERT INTO persons (here_name, bname, aname, country_id, cyr, lname_lat, fname_lat, lname_cyr, fname_cyr, lname_be, fname_be) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)') } || return undef;
	$sth->execute($here_name, $bname, $aname, $id, 0, $bname, $aname, $bname_cyr, $aname_cyr, $bname_cyr, $aname_cyr);
	
  
 }

sub country_info {
	my ($name) = @_;
	my %fix = ('Іспанія' => 'Гішпанія', 'Вялікабрытанія' => 'Вялікая Брытанія',  'Галандыя' => 'Нідэрланды', 'ЗША' => 'Злучаныя штаты Амерыкі', 'Германия' => 'Германія',  'Canada' => 'Канада', 'България' => 'Балгарыя', 'Россия' => 'Расія', 'Расія – Польшча' => 'Польшча', 'Словения' => 'Славенія', 'Украина' => 'Украіна');
	$name = exists ($fix{$name}) ? $fix{$name} : $name;
	foreach my $i (@{$ref}){
			my $c = $i->{'be'};
			if ($name eq $c){
				return ($i->{'id'}, $i->{'cyr'});
			}
			
			# say Dumper ($i);
			# exit;
		}
}