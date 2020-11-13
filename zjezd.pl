#!/usr/bin/env perl
use strict;
use utf8;
use 5.010;
use Mojolicious::Lite;
use EV; # libev-perl
use DBI;

app->secrets('adsfsdfas9qu4igddfdf425tanz');
app->defaults(gzip => 1);

app->attr(dbh => sub { # dbh attribute
	my $c = shift;
	my $dbh = DBI->connect("dbi:SQLite:crm.db","","", {sqlite_unicode => 1,  AutoCommit => 0, RaiseError => 1, sqlite_use_immediate_transaction => 1,});
	return $dbh;
});

hook before_dispatch => sub {
   my $self = shift;
   # notice: url must be fully-qualified or absolute, ending in '/' matters.
   $self->req->url->base(Mojo::URL->new(q{https://zjezd.philology.by/}));
};  
  
hook after_dispatch => sub {
    my $self = shift;
    # Was the response dynamic?
    return if $self->res->headers->header('Expires');
    # Allow spreadsheets to be cached
	$self->res->headers->header(Expires => 'Tue, 15 Jan 2019 21:47:38 GMT;');    
};

any '/' => sub {                    
	shift->reply->static('index.html');	
};

any '/api/persons.json' => sub {
	my $self = shift;
	my $dbh = $self->app->dbh;
	my $sth = eval { $dbh->prepare("SELECT P.id, P.here_name, P.aname, P.bname, P.country_id, lower(C.code) as code, C.be as country FROM persons AS P JOIN countries AS C ON P.country_id=C.id") } || return undef;
	$sth->execute;
    my $ref = $sth->fetchall_arrayref({});
	$self->render(json => $ref );
};

any '/api/stacks.json' => sub {
	my $self = shift;
	my $dbh = $self->app->dbh;
	my $sth = eval { $dbh->prepare("SELECT P.id, P.here_name, P.aname, P.bname, P.country_id, lower(C.code) as code, C.be as country FROM persons AS P JOIN countries AS C ON P.country_id=C.id") } || return undef;
	$sth->execute;
    my $ref = $sth->fetchall_arrayref({});
    $self->render(json => $ref );
};

any '/api/countries.json' => sub {
	my $self = shift;
	my $dbh = $self->app->dbh;
	my $sth = eval { $dbh->prepare("SELECT id, be FROM countries where be NOT NULL") } || return undef;
	$sth->execute;
    my $ref = $sth->fetchall_arrayref({});
    $self->render( json => $ref);
};

any '/api/schedule.json' => sub {
	my $self = shift;
	my $dbh = $self->app->dbh;
	my $sth = eval { $dbh->prepare("SELECT * from timetable") } || return undef;
	$sth->execute;
    my $ref = $sth->fetchall_arrayref({});
    $self->render(json => $ref );
};

any '/api/topics.json' => sub {
	my $self = shift;
	my $dbh = $self->app->dbh;
	my $sth = eval { $dbh->prepare("SELECT id, be, event_date, event_place, event_type, parent_id, event_start, event_end, lvl from global_topics ORDER BY event_date, event_start, event_end, lvl") } || return undef;
	$sth->execute;
    my $ref = $sth->fetchall_arrayref({});
    $self->render(json => $ref );
};

any '/api/topics2.json' => sub {
	my $self = shift;
	my $dbh = $self->app->dbh;
	my $sth = eval { $dbh->prepare("SELECT id, be, event_date, event_place, event_type, parent_id, event_start, event_end, lvl from global_topics ORDER BY event_date,  event_start, parent_id, lvl") } || return undef;
	$sth->execute;
    my $ref = $sth->fetchall_arrayref({});
    $self->render(json => $ref );

};

# get '/get' => sub {
    # my $self = shift;
    # my $col = $self->param( 'pid' );
    # my $dbh = $self->app->dbh;
	# my $sth = eval { $dbh->prepare('SELECT * from timetable WHERE person_id = ?') } || return undef;
	# $sth->execute($1, $2);
			# # my $ref;
			# # while ( my $row = $sth->fetchrow_arrayref() ) {
				# # push @$ref, @$row;
			# # }
	# my $ref = $sth->fetchall_arrayref({});
    # $self->render( json => $ref );
# };

app->start;
