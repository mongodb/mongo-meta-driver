# Definitions of utility functions for step definitions
import functools
import re
# import inspect

#
# Miscellaneous Useful functions
#

# utilities for marshalling data into and out of binary form
def pack_hex(hex_str):
  if len(hex_str) % 2 != 0:
    hex_str += '0'
  return hex_str.decode('hex')

# helper function for identifying empty arguments
def not_provided(arg):
  return (arg is None or arg.strip() == "")

# helper function for passing tests that don't make sense for this implementation
def trivial_pass():
  print "This test doesn't make sense with this implementation."

#
# Transform system implementation
#


# transform a series of arguments. will try to match each
# basically a dispatcher, calling the registered functions
# (registered by mktransform)
transform_registry = []

# transform decorator, used to declare transforms 
def transform(reg_str):
  global transform_registry
  def register_transform(func):
    global transform_registry
    # if we have a match
    # call the transform function
    # return what it returns / do what it does
    transform_registry.append([re.compile(reg_str), func])
  
  return register_transform

# transform an input string according to transform rules
def do_transform(arg_str):
  # if this argument is not a string, pass it through
  if type(arg_str) != str and type(arg_str) != unicode:
    return arg_str

  # if it is, attempt to match against transforms
  for re_func_pair in transform_registry:
    re, func = re_func_pair
    match = re.search(arg_str)
    # if we have a match at this transform
    if match is not None:
      transform_func_arguments = match.groups()
      return func(*transform_func_arguments)

  # otherwise pass through unchanged
  return arg_str

# TODO: enable you to do multiple transforms??

# declaring steps that can take transforms
# first argument is step type (given/when/then)
# second argument is regex that will be passed to given/when/then
def step_tr(step_decorator, reg_str):

  # modify the function the user provides
  @functools.wraps(step_decorator)
  def do_step_with_transform(user_func):

    # before calling the function, pass its arguments (capture groups) into transforms
    @functools.wraps(user_func)   # make Python give us useful line numbers
    def transform_wrapped(*args):

      # attempt to match against transforms
      # transform each argument. remember, each is a regex capture group
      modified_args = map(do_transform, list(args))
      user_func(*modified_args)

    # register the wrapped function using the step decorator
    step_decorator(reg_str)(transform_wrapped)

  # finally, return the function to work with Python's decorators
  return do_step_with_transform
