Rotate Alternative
==================

**Rotate Alternative** is an alternative to classical *logrotate* tool. 
It brings very similar functionallity, features openess and flexibility 
of the scripting environment and removes some most known *logrotate* 
limitations.

And of sure, it adds some features and it doesn't implement some
features of the original for now.

Removed *logrotate* Limitations
-------------------------------
* log directory and archive directory can be on **different drives**,
* it can **follow symbolic links** both for directories and files,
* it can **respect the subdirectories structure** of the log directory,
  so archive directory can have the same structure as original log 
  directory.
  
Additional Features
-------------------
* elegant, well documented and easy-to-understand YAML configuration 
  file,
* flexible and in fact unlimited possibility to define hooks while 
  "put file to archive" action and run them in mix with pre-build 
  actions in whatever required order.

Status
------
Currently in **pre-beta** version. All features are implemented, some 
of them such as *hooks* are untested.

Documentation
-------------

See configuration file. Is pretty well documented with possible values
listed and a lot of explains.


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-rotate`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-rotate`).
5. Create an [Issue][1] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.

[1]: http://github.com/martinkozak/rotate-alternative/issues
