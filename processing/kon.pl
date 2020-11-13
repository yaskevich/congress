#!/usr/bin/env perl
use strict;
use utf8;

use 5.010;
binmode STDOUT, ':encoding(UTF-8)';
use Mojolicious::Lite;
use DBI;
use Data::Dumper;
use Encode;
use HTML::Entities;
# use utf8::all;
# perl ./bmcrud.pl daemon --listen=http://*:3000


my $json = Mojo::JSON->new;
app->secret('olfosadlfaosdfasdf12354i123 9qu4iganz');
# connect to database
my $dbh = DBI->connect("dbi:SQLite:crm.db","","", {sqlite_unicode => 1}) or die "Could not connect";

# add helper methods for interacting with database
helper db => sub { $dbh };




helper select => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare('SELECT * FROM catspaw_folders') } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
};

helper list_links => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare("SELECT id, title, uri, fid, strftime('%s', date_added) as  date_added, dscr FROM catspaw_links WHERE active=1 ORDER BY date_added DESC") } || return undef;
  $sth->execute;
  return $sth;
};

helper list_stacks => sub {
  my $self = shift;
  my $sth = eval { $self->db->prepare("SELECT id, title, strftime('%s', accessed) as  accessed FROM catspaw_folders") } || return undef;
  $sth->execute;
  return $sth;
};

helper insert => sub {
  my $self = shift;
  my ($title, $age) = @_;                   
  # die ($title);
  my $sth = eval { $self->db->prepare('INSERT INTO catspaw_folders ( title) VALUES (?)') } || return undef;
  # my $sth = eval { $self->db->prepare('INSERT INTO catspaw_folders VALUES (AUTO_INCREMENT, ?)') } || return undef;
  # $sth->execute($title, $age);
  $sth->execute($title);
  return 1;
};

helper add => sub {
  my $self = shift;
  # die ($title);
  # my $sth = eval { $self->db->prepare('INSERT INTO catspaw_folders ( title) VALUES (?)') } || return undef;
  # my $sth = eval { $self->db->prepare('SELECT fid FROM catspaw_links ORDER BY ID DESC LIMIT 1') } || return undef;
  # $sth->execute;
  my $count = $dbh->selectrow_array('SELECT fid FROM catspaw_links ORDER BY ID DESC LIMIT 1', undef);
  # my $count = $dbh->selectrow_array('SELECT COUNT(*) FROM catspaw_links where', undef);
  # say Dumper ($sth);
  say $count;
  # $sth->execute($title);
  my ($title, $url, $cat) = @_;                   
  
  use POSIX;
  my $fid = $cat ? (isdigit($cat) ? $cat : 1) : $count;
  
  # unless ($p->{fid} ){
	# say 'last cat';
  # } else {
	# say 'into '.$p->{cat};
  # } 
  
  my $sth = eval { $self->db->prepare("INSERT INTO catspaw_links ( title, uri, fid, dscr, date_added) VALUES (?,?,?,?,DATETIME('now'))") } || return undef;
  $sth->execute($title, $url, $fid, '');
  $sth = eval { $self->db->prepare("UPDATE catspaw_folders SET accessed=DATETIME('now') WHERE id =?") } || return undef;
  $sth->execute($fid);
  return 1;
};

helper is_url_in_db => sub {
	my $self = shift;
	my ($uri) = @_; 
	
	return $self->db->selectrow_array("SELECT id FROM catspaw_links WHERE uri=?  LIMIT 1",undef,$uri) // 0;
};


# if statement didn't prepare, assume its because the table doesn't exist
# app->select || app->create_table;

# setup base route
any '/folders' => sub {
  my $self = shift;
  my $rows = $self->select;
  $self->stash( rows => $rows );
  $self->render('folders');
};

# Поиск и получение информации объекта (find/show)
any '/links.js' => sub {
	my $self = shift;
	my $sth = $self->list_links;
    my $ref = $sth->fetchall_arrayref({});
    
    $self->render_json( $ref );
};

any '/stacks.js' => sub {
	my $self = shift;
	my $sth = $self->list_stacks;
    my $ref = $sth->fetchall_arrayref({});
    
    $self->render_json( $ref );
};

any '/stacks.json' => sub {
	my $self = shift;
	my $sth = $self->list_stacks;
    my $ref = $sth->fetchall_hashref('id');
    
    $self->render_json( $ref );
};



any '/' => sub {
  my $self = shift;
  # my $rows = $self->list_links;
  # $self->stash( rows => $rows );
  $self->render('index');
};

# get '/search_db' => sub {
    # my $self = shift;
    # my $col = $self->param( 'col' );
    # my $sth = $dbh->prepare( "SELECT $col FROM catspaw_folders" );
    # $sth->execute();
    # # my $ref;
    # # while ( my $row = $sth->fetchrow_arrayref() ) {
        # # push @$ref, @$row;
    # # }
	# my $ref = $sth->fetchall_arrayref({});
    # $self->render( json => $ref );
# };

# setup route which receives data and returns to /


app->start;

