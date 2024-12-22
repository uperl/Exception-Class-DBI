# Exception::Class::DBI ![linux](https://github.com/uperl/Exception-Class-DBI/workflows/linux/badge.svg) ![macos](https://github.com/uperl/Exception-Class-DBI/workflows/macos/badge.svg) ![windows](https://github.com/uperl/Exception-Class-DBI/workflows/windows/badge.svg)

DBI Exception objects

# Name

Exception::Class::DBI - DBI Exception objects

# Synopsis

```perl
use DBI;
use Exception::Class::DBI;

my $dbh = DBI->connect($dsn, $user, $pass, {
    PrintError  => 0,
    RaiseError  => 0,
    HandleError => Exception::Class::DBI->handler,
});

eval { $dbh->do($sql) };

if (my $ex = $@) {
    print STDERR "DBI Exception:\n";
    print STDERR "  Exception Type: ", ref $ex, "\n";
    print STDERR "  Error:          ", $ex->error, "\n";
    print STDERR "  Err:            ", $ex->err, "\n";
    print STDERR "  Errstr:         ", $ex->errstr, "\n";
    print STDERR "  State:          ", $ex->state, "\n";
    print STDERR "  Return Value:   ", ($ex->retval || 'undef'), "\n";
}
```

# Description

This module offers a set of DBI-specific exception classes. They inherit from
Exception::Class, the base class for all exception objects created by the
[Exception::Class](https://metacpan.org/pod/Exception::Class) module from the CPAN.
Exception::Class::DBI itself offers a single class method, `handler()`, that
returns a code reference appropriate for passing to the DBI `HandleError`
attribute.

The exception classes created by Exception::Class::DBI are designed to be
thrown in certain DBI contexts; the code reference returned by `handler()`
and passed to the DBI `HandleError` attribute determines the context and
throws the appropriate exception.

Each of the Exception::Class::DBI classes offers a set of object accessor
methods in addition to those provided by Exception::Class. These can be used
to output detailed diagnostic information in the event of an exception.

# Interface

Exception::Class::DBI inherits from Exception::Class, and thus its entire
interface. Refer to the Exception::Class documentation for details.

## Class Method

- `handler`

    ```perl
    my $dbh = DBI->connect($data_source, $username, $auth, {
        PrintError  => 0,
        RaiseError  => 0,
        HandleError => Exception::Class::DBI->handler
    });
    ```

    This method returns a code reference appropriate for passing to the DBI
    `HandleError` attribute. When DBI encounters an error, it checks its
    `PrintError`, `RaiseError`, and `HandleError` attributes to decide what to
    do about it. When `HandleError` has been set to a code reference, DBI
    executes it, passing it the error string that would be printed for
    `PrintError`, the DBI handle object that was executing the method call that
    triggered the error, and the return value of that method call (usually
    `undef`). Using these arguments, the code reference provided by `handler()`
    determines what type of exception to throw. Exception::Class::DBI contains the
    subclasses detailed below, each relevant to the DBI handle that triggered the
    error.

# Classes

Exception::Class::DBI creates a number of exception classes, each one specific
to a particular DBI error context. Most of the object methods described below
correspond to like-named attributes in the DBI itself. Thus the documentation
below summarizes the DBI attribute documentation, so you should refer to
[DBI](https://metacpan.org/pod/DBI) itself for more in-depth information.

## Exception::Class::DBI

All of the Exception::Class::DBI classes documented below inherit from
Exception::Class::DBI. It offers the several object methods in addition to
those it inherits from _its_ parent, Exception::Class. These methods
correspond to the [DBI dynamic attributes](https://metacpan.org/pod/DBI#DBI-Dynamic-Attributes), as
well as to the values passed to the `handler()` exception handler via the DBI
`HandleError` attribute. Exceptions of this base class are only thrown when
there is no DBI handle object executing, e.g. in the DBI `connect()`
method. **Note:** This functionality is not yet implemented in DBI -- see the
discussion that starts here:
[http://archive.develooper.com/dbi-dev@perl.org/msg01438.html](http://archive.develooper.com/dbi-dev@perl.org/msg01438.html).

- `error`

    ```perl
    my $error = $ex->error;
    ```

    Exception::Class::DBI actually inherits this method from Exception::Class. It
    contains the error string that DBI prints when its `PrintError` attribute is
    enabled, or `die`s with when its <RaiseError> attribute is enabled.

- `err`

    ```perl
    my $err = $ex->err;
    ```

    Corresponds to the `$DBI::err` dynamic attribute. Returns the native database
    engine error code from the last driver method called.

- `errstr`

    ```perl
    my $errstr = $ex->errstr;
    ```

    Corresponds to the `$DBI::errstr` dynamic attribute. Returns the native
    database engine error message from the last driver method called.

- `state`

    ```perl
    my $state = $ex->state;
    ```

    Corresponds to the `$DBI::state` dynamic attribute. Returns an error code in
    the standard SQLSTATE five character format.

- `retval`

    ```perl
    my $retval = $ex->retval;
    ```

    The first value being returned by the DBI method that failed (typically
    `undef`).

- `handle`

    ```perl
    my $db_handle = $ex->handle;
    ```

    The DBI handle appropriate to the exception class. For
    Exception::Class::DBI::DRH, it will be a driver handle. For
    Exception::Class::DBI::DBH it will be a database handle. And for
    Exception::Class::DBI::STH it will be a statement handle. If there is no
    handle thrown in the exception (because, say, the exception was thrown before
    a driver handle could be created), the `handle` will be `undef`.

## Exception::Class::DBI::H

This class inherits from [Exception::Class::DBI](#exception-class-dbi), and
is the base class for all DBI handle exceptions (see below). It will not be
thrown directly. Its methods correspond to the [DBI attributes common to all
handles](https://metacpan.org/pod/DBI#ATTRIBUTES-COMMON-TO-ALL-HANDLES).

- `warn`

    ```perl
    my $warn = $ex->warn;
    ```

    Boolean value indicating whether DBI warnings have been enabled. Corresponds
    to the DBI `Warn` attribute.

- `active`

    ```perl
    my $active = $ex->active;
    ```

    Boolean value indicating whether the DBI handle that encountered the error is
    active. Corresponds to the DBI `Active` attribute.

- `kids`

    ```perl
    my $kids = $ex->kids;
    ```

    For a driver handle, Kids is the number of currently existing database handles
    that were created from that driver handle. For a database handle, Kids is the
    number of currently existing statement handles that were created from that
    database handle. Corresponds to the DBI `Kids` attribute.

- `active_kids`

    ```perl
    my $active_kids = $ex->active_kids;
    ```

    Like `kids`, but only counting those that are `active` (as
    above). Corresponds to the DBI `ActiveKids` attribute.

- `compat_mode`

    ```perl
    my $compat_mode = $ex->compat_mode;
    ```

    Boolean value indicating whether an emulation layer (such as Oraperl) enables
    compatible behavior in the underlying driver (e.g., DBD::Oracle) for this
    handle. Corresponds to the DBI `CompatMode` attribute.

- `inactive_destroy`

    ```perl
    my $inactive_destroy = $ex->inactive_destroy;
    ```

    Boolean value indicating whether the DBI has disabled the database engine
    related effect of `DESTROY`ing a handle. Corresponds to the DBI
    `InactiveDestroy` attribute.

- `trace_level`

    ```perl
    my $trace_level = $ex->trace_level;
    ```

    Returns the DBI trace level set on the handle that encountered the
    error. Corresponds to the DBI `TraceLevel` attribute.

- `fetch_hash_key_name`

    ```perl
    my $fetch_hash_key_name = $ex->fetch_hash_key_name;
    ```

    Returns the attribute name the DBI `fetchrow_hashref()` method should use to
    get the field names for the hash keys. Corresponds to the DBI
    `FetchHashKeyName` attribute.

- `chop_blanks`

    ```perl
    my $chop_blanks = $ex->chop_blanks;
    ```

    Boolean value indicating whether DBI trims trailing space characters from
    fixed width character (CHAR) fields. Corresponds to the DBI `ChopBlanks`
    attribute.

- `long_read_len`

    ```perl
    my $long_read_len = $ex->long_read_len;
    ```

    Returns the maximum length of long fields ("blob", "memo", etc.) which the DBI
    driver will read from the database automatically when it fetches each row of
    data. Corresponds to the DBI `LongReadLen` attribute.

- `long_trunc_ok`

    ```perl
    my $long_trunc_ok = $ex->long_trunc_ok;
    ```

    Boolean value indicating whether the DBI will truncate values it retrieves from
    long fields that are longer than the value returned by
    `long_read_len()`. Corresponds to the DBI `LongTruncOk` attribute.

- `taint`

    ```perl
    my $taint = $ex->taint;
    ```

    Boolean value indicating whether data fetched from the database is considered
    tainted. Corresponds to the DBI `Taint` attribute.

## Exception::Class::DBI::DRH

DBI driver handle exceptions objects. This class inherits from
[Exception::Class::DBI::H](#exception-class-dbi-h), and offers no extra
methods of its own.

## Exception::Class::DBI::DBH

DBI database handle exceptions objects. This class inherits from
[Exception::Class::DBI::H](#exception-class-dbi-h) Its methods correspond
to the [DBI database handle attributes](https://metacpan.org/pod/DBI#Database-Handle-Attributes).

- `auto_commit`

    ```perl
    my $auto_commit = $ex->auto_commit;
    ```

    Returns true if the database handle `AutoCommit` attribute is
    enabled. meaning that database changes cannot be rolled back. Corresponds to
    the DBI database handle `AutoCommit` attribute.

- `db_name`

    ```perl
    my $db_name = $ex->db_name;
    ```

    Returns the "name" of the database. Corresponds to the DBI database handle
    `Name` attribute.

- `statement`

    ```perl
    my $statement = $ex->statement;
    ```

    Returns the statement string passed to the most recent call to the DBI
    `prepare()` method in this database handle. If it was the `prepare()` method
    that encountered the error and triggered the exception, the statement string
    will be the statement passed to `prepare()`. Corresponds to the DBI database
    handle `Statement` attribute.

- `row_cache_size`

    ```perl
    my $row_cache_size = $ex->row_cache_size;
    ```

    Returns the hint to the database driver indicating the size of the local row
    cache that the application would like the driver to use for future `SELECT`
    statements. Corresponds to the DBI database handle `RowCacheSize` attribute.

## Exception::Class::DBI::STH

DBI statement handle exceptions objects. This class inherits from
[Exception::Class::DBI::H](#exception-class-dbi-h) Its methods correspond
to the [DBI statement handle attributes](https://metacpan.org/pod/DBI#Statement-Handle-Attributes).

- `num_of_fields`

    ```perl
    my $num_of_fields = $ex->num_of_fields;
    ```

    Returns the number of fields (columns) the prepared statement will
    return. Corresponds to the DBI statement handle `NUM_OF_FIELDS` attribute.

- `num_of_params`

    ```perl
    my $num_of_params = $ex->num_of_params;
    ```

    Returns the number of parameters (placeholders) in the prepared
    statement. Corresponds to the DBI statement handle `NUM_OF_PARAMS` attribute.

- `field_names`

    ```perl
    my $field_names = $ex->field_names;
    ```

    Returns a reference to an array of field names for each column. Corresponds to
    the DBI statement handle `NAME` attribute.

- `type`

    ```perl
    my $type = $ex->type;
    ```

    Returns a reference to an array of integer values for each column. The value
    indicates the data type of the corresponding column. Corresponds to the DBI
    statement handle `TYPE` attribute.

- `precision`

    ```perl
    my $precision = $ex->precision;
    ```

    Returns a reference to an array of integer values for each column. For
    non-numeric columns, the value generally refers to either the maximum length
    or the defined length of the column. For numeric columns, the value refers to
    the maximum number of significant digits used by the data type (without
    considering a sign character or decimal point). Corresponds to the DBI
    statement handle `PRECISION` attribute.

- `scale`

    ```perl
    my $scale = $ex->scale;
    ```

    Returns a reference to an array of integer values for each column. Corresponds
    to the DBI statement handle `SCALE` attribute.

- `nullable`

    ```perl
    my $nullable = $ex->nullable;
    ```

    Returns a reference to an array indicating the possibility of each column
    returning a null. Possible values are 0 (or an empty string) = no, 1 = yes, 2
    &#x3d; unknown. Corresponds to the DBI statement handle `NULLABLE` attribute.

- `cursor_name`

    ```perl
    my $cursor_name = $ex->cursor_name;
    ```

    Returns the name of the cursor associated with the statement handle, if
    available. Corresponds to the DBI statement handle `CursorName` attribute.

- `param_values`

    ```perl
    my $param_values = $ex->param_values;
    ```

    Returns a reference to a hash containing the values currently bound to
    placeholders. Corresponds to the DBI statement handle `ParamValues`
    attribute.

- `statement`

    ```perl
    my $statement = $ex->statement;
    ```

    Returns the statement string passed to the DBI `prepare()`
    method. Corresponds to the DBI statement handle `Statement` attribute.

- `rows_in_cache`

    ```perl
    my $rows_in_cache = $ex->rows_in_cache;
    ```

    the number of unfetched rows in the cache if the driver supports a local row
    cache for `SELECT` statements. Corresponds to the DBI statement handle
    `RowsInCache` attribute.

## Exception::Class::DBI::Unknown

Exceptions of this class are thrown when the context for a DBI error cannot be
determined. Inherits from [Exception::Class::DBI](#exception-class-dbi),
but implements no methods of its own.

# Note

**Note:** Not _all_ of the attributes offered by the DBI are exploited by
these exception classes. For example, the `PrintError` and `RaiseError`
attributes seemed redundant. But if folks think it makes sense to include the
missing attributes for the sake of completeness, let me know. Enough interest
will motivate me to get them in.

# Subclassing

It is possible to subclass Exception::Class::DBI. The trick is to subclass its
subclasses, too. Similar to subclassing DBI itself, this means that the handle
subclasses should exist as subnamespaces of your base subclass.

It's easier to explain with an example. Say that you wanted to add a new
method to all DBI exceptions that outputs a nicely formatted error message.
You might do it like this:

```perl
package MyApp::Ex::DBI;
use base 'Exception::Class::DBI';

sub full_message {
    my $self = shift;
    return $self->SUPER::full_message unless $self->can('statement');
    return $self->SUPER::full_message
        . ' [for Statement "'
        . $self->statement . '"]';
}
```

You can then use this subclass just like Exception::Class::DBI itself:

```perl
my $dbh = DBI->connect($dsn, $user, $pass, {
    PrintError  => 0,
    RaiseError  => 0,
    HandleError => MyApp::Ex::DBI->handler,
});
```

And that's all well and good, except that none of Exception::Class::DBI's own
subclasses inherit from your class, so most exceptions won't be able to use
your spiffy new method.

The solution is to create subclasses of both the Exception::Class::DBI
subclasses and your own base subclass, as long as they each use the same
package name as your subclass, plus "H", "DRH", "DBH", "STH", and "Unknown".
Here's what it looks like:

```perl
package MyApp::Ex::DBI::H;
use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::H';

package MyApp::Ex::DBI::DRH;
use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::DRH';

package MyApp::Ex::DBI::DBH;
use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::DBH';

package MyApp::Ex::DBI::STH;
use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::STH';

package MyApp::Ex::DBI::Unknown;
use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::Unknown';
```

And then things should work just spiffy! Of course, you probably don't need
the H subclass unless you want to add other methods for the DRH, DBH, and STH
classes to inherit from.

# To Do

- I need to figure out a non-database specific way of testing STH exceptions.
DBD::ExampleP works well for DRH and DBH exceptions, but not so well for
STH exceptions.

# Support

This module is stored in an open [GitHub
repository](http://github.com/uperl/Exception-Class-DBI/). Feel free to fork
and contribute!

Please file bug reports via [GitHub
Issues](http://github.com/uperl/Exception-Class-DBI/issues/).

# Author

Original Author is David E. Wheeler <david@justatheory.com>

Current maintainer is Graham Ollis <plicease@cpan.org>

# See Also

You should really only be using this module in conjunction with Tim Bunce's
[DBI](https://metacpan.org/pod/DBI), so it pays to be familiar with its documentation.

See the documentation for Dave Rolsky's [Exception::Class](https://metacpan.org/pod/Exception::Class)
module for details on the methods this module's classes inherit from
it. There's lots more information in these exception objects, so use them!

# AUTHORS

- David E. Wheeler <david@justatheory.com>
- Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2002-2024 by David E. Wheeler.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
