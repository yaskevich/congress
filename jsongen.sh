perl zjezd.pl get /api/persons.json > public/json/persons.json
perl zjezd.pl get /api/stacks.json > public/json/stacks.json
perl zjezd.pl get /api/countries.json > public/json/countries.json
perl zjezd.pl get /api/schedule.json > public/json/schedule.json
perl zjezd.pl get /api/topics.json > public/json/topics.json
perl zjezd.pl get /api/topics2.json > public/json/topics2.json
chown -R www-data:www-data public/json
