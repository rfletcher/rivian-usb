##
# Convert ASCII letters to lowercase
#
# Usage:
#   "FooBar" | __tolower # => "foobar"
#
def __tolower:
  if type == "string" then
    ascii_downcase
  else
    .
  end
;

##
# Check if input is truthy.
#
# For arrays, objects and strings truthy means non-empty. Otherwise it means
# non-null.
#
# Usage:
#   [1,[],3,null] | map(__truthy) # => [true,false,true,false]
#
def __truthy:
  type as $type |

  if $type == "boolean" then
    .
  elif $type == "object" then
    if ( keys | __truthy ) then true else false end
  elif $type == "array" then
    if ( length > 0 ) then true else false end
  elif $type == "number" then
    . != 0
  elif . == null or . == "" then
    false
  else
    true
  end
;

##
# Wrap non-array input in an array
#
# Usage:
#   1     | __as_array # => [1]
#   [1,2] | __as_array # => [1,2]
#
def __as_array:
  if type == "array" then
    .
  elif . == null then
    null
  else
    [.]
  end
;

##
# Coerce a string value to a more appropriate type
#
# Usage:
#   "foo"  | __coerce # => "foo"
#   "true" | __coerce # => true
#   "-42"  | __coerce # => -42
#
def __coerce:
  if type == "string" then
    . as $original_value | __tolower |

    if . == "true" or . == "false" then
      . == "true"
    elif . == "null" then
      null
    elif test("^-?\\d+(\\.\\d+)?$"; "") then
      tonumber
    else
      $original_value
    end
  else
    .
  end
;

##
# Remove non-truthy values from an array or object.
#
# Usage:
#   [1,[],3,null] | __compact # => [1,3]
#
def __compact:
  if type == "array" then
    reduce .[] as $i ( [];
      . as $acc | $i | __compact |

      if . == false or __truthy then
        $acc + [.]
      else
        $acc
      end
    )
  elif type == "object" then
    to_entries | reduce .[] as $i ( {};
      . as $acc | $i.value | __compact |

      if . == false or __truthy then
        $acc + { "\($i.key)": . }
      else
        $acc
      end
    )
  else
    .
  end
;

##
# Flatten a multi-dimensional array
#
# DEPRECATED: jq 1.5 introduced a native `flatten`
#
# Usage:
#   [[1,2],[[3],4]] | __flatten # => [1,2,3,4]
#
def __flatten:
  flatten
;

##
# Convert ISO-8601 times, such as those returned by AWS API calls, to Unix epoch
#
# Usage:
#   "2017-03-20T15:50:05+00:00" | __fromdateiso8601 # => 1490025005
#   "2017-03-20T15:50:05.000Z"  | __fromdateiso8601 # => 1490025005
#   "2017-03-20T15:50:05Z"      | __fromdateiso8601 # => 1490025005
#
def __fromdateiso8601:
  if type == "string" then
    . | sub( "\\.\\d+"; "" ) |
    . | sub( "Z$"; "+0000" ) |
    capture( "(?<no_tz>.*)(?<tz_sgn>[-+])(?<tz_hr>\\d{2}):?(?<tz_min>\\d{2})$") |
    ( .no_tz + "Z" | fromdateiso8601 ) -
    ( .tz_sgn + "60" | tonumber ) *
    ( ( .tz_hr | tonumber ) * 60 + ( .tz_min | tonumber ) )
  else
    .
  end
;

##
# Capitalize each word in a string
#
# Usage:
#   "hello world" | __capitalize # => "Hello World"
#
def __capitalize:
  if type == "string" then
    def c: sub("\\b(?<i>[[:lower:]])"; .i | ascii_upcase);
    ascii_downcase | c as $c | if . == $c then $c else ($c | c) end
  else
    .
  end
;

##
# Convert ISO-8601 times, such as those returned by AWS API calls, to their
# relative age in seconds
#
# Usage:
#   "2017-03-20T15:50:05.000Z" | __age # => 47
#
def __age:
  if . == null or . == "" then
    null
  else
    ( now - ( . | __fromdateiso8601 ) ) | floor
  end
;

##
# Convert an array of hashes to a hash of hashes
#
# Usage:
#   [{"a": 1, "b": 2},
#    {"a": 2, "b": 3}
#   ] | __hoist( "a" ) # => { "1": [{ "b": 2 }], "2": [{ "b": 3 }] }
#
def __hoist( key ):
  reduce .[] as $i ( {}; . |
    ( $i[key] | tostring ) as $key |
    .[$key] as $l |
    .[$key] = ( ( $l // [] ) + [$i | del( .[key] )] )
  )
;

##
# Find the intersection of 2 or more arrays
#
# Usage:
#   [[1,2,4], [2,4,5], [4,5,6]] | __intersetion #=> [4],
#
def __intersection:
  def i(y): ((unique + (y|unique)) | sort) as $sorted
  | reduce range(1; $sorted|length) as $i
      ([]; if $sorted[$i] == $sorted[$i-1] then . + [$sorted[$i]] else . end) ;
  reduce .[1:][] as $a (.[0]; i($a))
;

##
# Merge an array of keys and an array of values into an object
#
# Usage:
#   [1,2] | __objectify( ["a","b"] ) # => { "a": 1, "b": 2 }
#
def __objectify( keys ):
  . as $in
  | reduce range( 0; keys | length) as $i ( {}; .[keys[$i]] = $in[$i] )
;

##
# Select a value from an object with a simple path
#
# Usage:
#   {"a":{"b":1}} | __select( "a/b" ) # => 1
#
def __select( path ):
  . | getpath(path | split("/") ? // "")
;

##
# Sort an array of hostnames naturally
#
# Usage:
#   ["api-10","api-2"] | __sort_hostnames # => ["api-2", "api-10"]
#
def __sort_hostnames:
  # split into prefix/index/suffix so index is sorted numerically
  map( . as $hostname |
    capture( "(?<prefix>^[^0-9]+)(?<index>[0-9]*)(?<suffix>.*$)" ) |
    [ .prefix,
      ( ( ( if .index == "" then null else .index end ) // 0 ) | tonumber ),
      .suffix,
      $hostname
    ]
  ) | sort |
  # return just the original hostname
  map( .[3] )
;

##
# Strip leading and tailing whitespace from a string
#
# Usage:
#   "  foo " | __trim # => "foo"
#
def __trim:
  gsub( "(^[ \t\n]+|[ \t\n]+$)"; "" )
;

##
# Convert keys in an object to lowercase
#
# Usage:
#   { "Foo": true } | __keys_tolower # => { "foo": true }
#
def __keys_tolower:
  . | to_entries | map( .key = ( .key | __tolower ) ) | from_entries
;

##
# Convert ASCII letters to uppercase
#
# Usage:
#   "FooBar" | __toupper # => "FOOBAR"
#
def __toupper:
  if type == "string" then
    ascii_upcase
  else
    .
  end
;

##
# Normalize an instance name per our historic naming conventions
#
# Usage:
#   "FooBar-va-1 (c)" | __normalize_name # => "FooBar-va-1"
#
def __normalize_name:
  sub( "[(].*[)]$"; "" ) | gsub( "[^A-Za-z0-9-]"; "" )
;

##
# Normalize an instance name for use as a hostname
#
# Usage:
#   "FooBar-va-1 (c)" | __normalize_hostname # => "foobar-va-1"
#
def __normalize_hostname:
  __normalize_name | __tolower
;

##
# Translate an EC2 instance type into its number of base units. See the table
# at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/apply_ri.html#apply-regional-ri
#
# Usage:
#   "c4.xlarge" | __ec2_instance_units # => 8
#
def __ec2_instance_units:
  split( "." ) | last |

  if . == "nano" then
    0.25
  elif . == "micro" then
    0.5
  elif . == "small" then
    1
  elif . == "medium" then
    2
  elif . == "large" then
    4
  elif . == "xlarge" then
    8
  elif . == "2xlarge" then
    16
  elif . == "4xlarge" then
    32
  elif . == "8xlarge" then
    64
  elif . == "9xlarge" then
    72
  elif . == "10xlarge" then
    80
  elif . == "12xlarge" then
    96
  elif . == "16xlarge" then
    128
  elif . == "18xlarge" then
    144
  elif . == "24xlarge" then
    192
  elif . == "32xlarge" then
    256
  else
    0
  end
;
