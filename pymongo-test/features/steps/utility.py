# Definitions of utility functions for step definitions
#
# Useful functions
#
# utilities for marshalling data into and out of binary form
def pack_hex(hex_str):
  if len(hex_str) % 2 != 0:
    hex_str += '0'
  return hex_str.decode('hex')

# helper function for identifying empty arguments
def not_provided(arg):
  return (arg is None or arg.strip() == "")

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

# TODO: enable you to do multiple transforms??

# declaring steps that can take transforms
# first argument is step type (given/when/then)
# second argument is regex that will be passed to given/when/then
def step_tr(step_decorator, reg_str):

  # modify the function the user provides
  def do_step_with_transform(user_func):

    # before calling the function, pass its arguments (capture groups) into transforms
    def transform_wrapped(*args):

      # used by map to check individual argument for a match, and call the corresponding function
      # remember, each argument is a regex capture group
      def dispatch(arg_str):
        for re_func_pair in transform_registry:
          re, func = re_func_pair
          match = re.search(arg_str)
          # if we have a match at this transform
          if match is not None:
            transform_func_arguments = match.groups()
            return func(*transform_func_arguments)

        # otherwise pass through unchanged
        return arg

      # attempt to match against transforms
      modified_args = args.map(dispatch)
      user_func(*modified_args)

    # register the wrapped function using the step decorator
    step_decorator(reg_str)(transform_wrapped)

  # finally, return the function to work with Python's decorators
  return do_step_with_transform


      # mod_args = []
      # for arg_str in args:
      #   # we're basically
      #   mod_arg_str
      #   for re_func_pair in transform_registry:
      #     re, func = re_func_pair
      #     if re.match(arg_str):
      #       mod_args.append()