Greenwich...
================================

...has been helping Rails developers work with custom time zones since 2011.

![Greenwich](http://www.thekompanee.com/public_files/greenwich.jpg)

Rails 2.1 brought much-needed improvements to working with time zones in Rails.
But even now, with Rails 3 out and kicking ass, allowing users to _specify_ the time
zone they would like to use for a given date is still a PITA.

Enter Greenwich

You too can now give your users the **POWER** of choosing a time zone via a
standard web form.  Maybe you have a system that allows people to enter appointments
for Widgets, Inc.  Since they make the best widgets in the world, they're very popular
internationally.  You would like a system which allows your users to enter not just the
_time_ of an appointment but also the time _zone_ in which the appointment is located.

Still interested?  Read on intrepid traveler.

Installation
--------------------------------

    gem install greenwich

Initialization
--------------------------------

You add Greenwich to your models like so:

    date_with_time_zone :field_name

By default Greenwich looks for a few different columns in your model depending on the
field name you passed in.  Let's look at some examples.

Meta-Programming Magic
--------------------------------

** DateTime Field Lookup **
Greenwich will lookup `:field_name` based on a couple different standard column suffixes.

  * `_at`
  * `_datetime`

For example, if you specify:

    date_with_time_zone :start

Greenwich will look for the columns `start_at` and `start_datetime` (in that order).

** Time Zone Field Lookup **
Time Zone lookups default to a per-field or per-model specification.  If you specify:

    date_with_time_zone :start

Greenwich will lookup the time zone from `:start_time_zone` first, and if it doesn't
find a field by that name, it will use `:time_zone`.

Usage
--------------------------------
  * Note: These examples assume the application's default time zone is set to UTC.
    If you have modified the default time zone, directly accessing your DateTime field
    will render it in _that_ time zone and not UTC.

When working with your instances, Greenwich will convert to the proper time zone when
you access it.  So if you've previously saved a DateTime like this:

    my_model.start = Time.strptime('2011-07-04 13:00:00 -600 CST')

Then that will result in your model returning the following values (assuming these
particular columns exist in the database):

    my_model.start_at           # => 2011-07-04 19:00:00 GMT
    my_model.start_datetime     # => 2011-07-04 19:00:00 GMT
    my_model.start_time_zone    # => 'Central Standard Time'
    my_model.time_zone          # => 'Central Standard Time'

Whereas asking Greenwich for the value of `start` will result in:

    my_model.start              # => 2011-07-04 13:00:00 CST

If you then change your time zone:

    my_model.start_time_zone = 'Eastern Standard Time'

Then calling the attributes on your model will result in the following:

    my_model.start_at           # => 2011-07-04 19:00:00 GMT
    my_model.start_datetime     # => 2011-07-04 19:00:00 GMT
    my_model.start_time_zone    # => 'Eastern Standard Time'
    my_model.time_zone          # => 'Eastern Standard Time'

And again, asking Greenwich for the value of `start` will result in:

    my_model.start              # => 2011-07-04 13:00:00 EST

Issues
------

If you have problems, please create a [Github issue](https://github.com/jfelchner/validates_truthiness/issues).

Credits
-------

![thekompanee](http://www.thekompanee.com/public_files/kompanee-github-readme-logo.png)

validates_truthiness is maintained by [The Kompanee, Ltd.](http://www.thekompanee.com)

The names and logos for The Kompanee are trademarks of The Kompanee, Ltd.

License
-------

validates_truthiness is Copyright &copy; 2011 The Kompanee. It is free software, and may be redistributed under the terms specified in the LICENSE file.

