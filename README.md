# twilight-imperium-iv-mapper

learn perl: https://learnxinyminutes.com/docs/perl/

Perl Dependencies
-----------------
* Mojolicious
* YAML
* Hash::MD5

Installation
------------

* install cpanm (on mac this is: `brew install cpanm`)
* install the above dependencies with `cpanm [module_name]`

for example:
```
brew install cpanm
cpanm Mojolicious
cpan Mojolicious
cpanm YAML
cpanm Hash::MD5
```


Running
-------

to start on port 3000:
```
./ti4p.pl daemon
```
