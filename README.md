rb.rotate
=========

**rb.rotate** is an alternative to classical `logrotate` tool. 
It implements very similar functionallity, features openess and 
flexibility of the scripting environment and removes some most known 
`logrotate` limitations.

And of sure, it adds some features and it doesn't implement some
features of the original for now.

### Removed `logrotate` Limitations

* log directory and archive directory can be on **different drives**,
* it can **follow symbolic links** both for directories and files,
* it can **respect the subdirectories structure** of the log directory,
  so archive directory can have the same structure as original log 
  directory.
  
### Additional Features

* elegant, well documented and easy-to-understand [YAML][2] configuration 
  file,
* flexible and in fact unlimited possibility to define hooks while 
  "put file to archive" action and run them in mix with pre-build 
  actions in whatever required order.
  
Installation
------------

After installing the `rb.rotate` gem, simply type following as root and 
then add the `rb.rotate` entry to cron.

    rb.rotate install

Be warn, it works for *Linux* and *FreeBSD* only. On other platforms,
please: 

1. copy initial configuration files in `<gem-path>/lib/rb.rotate/install` 
to appropriate location on your platform (remove the `.initial` extension,
of sure),
2. create the `<gem-path>/lib/paths.conf` file with path to 
`rotate.yaml` file,
3. change paths in `rotate.yaml` file to directories appropriate for 
your platfom,
4. [report][1] back to project output of `rb.rotate sysname` and 
appropriate configuration locations for including in next release.


Status
------
Currently in **pre-beta** version. All features are implemented, some 
of them such as *hooks* are untested.

### Documentation

See the configuration file. It's pretty well documented with possible values
listed and a lot of explaining.


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][1] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.


Copyright
---------

Copyright (c) 2010 [Martin Kozák][3]. See `LICENSE.txt` for
further details.

[1]: http://github.com/martinkozak/rotate-alternative/issues
[2]: http://www.yaml.org/
[3]: http://www.martinkozak.net/
