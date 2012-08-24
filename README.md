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

    time_with_time_zone :your_column_name_utc

By default, Greenwich removes the `_utc` from the column name and uses
the resulting string as the composed field.

For example, the above call would result in a composed field called
`your_column_name`.

### Time Zones ###

Greenwich will try to use convention to choose a time zone column name
based on the time field you choose.

    time_with_time_zone :started_at_utc

Will look for a column called `started_at_time_zone` which contains the
time zone for the time field.

#### Custom Time Zone ####

If you want to use the same time zone for multiple time fields or just
don't like the custom one we choose for you, you can pass a `:time_zone`
option which will override our default.

    time_with_time_zone :started_at_utc, :time_zone => :started_at_zone

Will tell Greenwich that when the user accesses the `started_at` method,
it will use the information from the `started_at_zone` column for its
time zone.

### Convention... but missing a little configuration ###

We're on `v1.0.0` and have more features planned in the future, however
for now, all columns passed to `time_with_time_zone` _must_ end in `_utc`.

Usage
--------------------------------
  **Note:** _These examples assume the application's default time zone is set to UTC.
  If you have modified the default time zone, directly accessing your DateTime field
  will render it in **that** time zone and not UTC._

When working with your instances, Greenwich will convert to the proper time zone when
you access it.  So if you've defined a Greenwich time field like this:

    time_with_time_zone :started_at_utc

And if you've previously saved a DateTime like this:

    my_model.started_at_utc       = Time.utc(2011, 7, 4, 13, 0, 0)
    my_model.started_at_time_zone = 'Alaska'

Then that will result in your model returning the following values (assuming these
particular columns exist in the database):

    my_model.started_at_utc         # => ActiveSupport::TimeWithZone 2011-07-04 13:00:00 UTC
    my_model.started_at_time_zone   # => ActiveSupport::TimeZone     'Alaska'

Whereas asking Greenwich for the value of `started_at` will result in:

    my_model.started_at             # => ActiveSupport::TimeWithZone 2011-07-04 04:00:00 AKDT

If you then change your time zone:

    my_model.started_at_time_zone = 'Hawaii'

Then calling the attributes on your model will result in the following:

    my_model.started_at_utc         # => ActiveSupport::TimeWithZone 2011-07-04 13:00:00 UTC
    my_model.started_at_time_zone   # => ActiveSupport::TimeZone 'Hawaii'

And again, asking Greenwich for the value of `started_at` will result in:

    my_model.started_at             # => ActiveSupport::TimeWithZone 2011-07-04 03:00:00 HADT

Issues
------

If you have problems, please create a [Github issue](issues).

Credits
-------

![chirrpy](https://dl.dropbox.com/s/f9s2qd0kmbc8nwl/github_logo.png?dl=1)

greenwich is maintained by [Chrrpy, LLC](http://chirrpy.com)

The names and logos for Chirrpy are trademarks of Chrrpy, LLC

License
-------

greenwich is Copyright &copy; 2011 Chirrpy. It is free software, and may be redistributed under the terms specified in the LICENSE file.
