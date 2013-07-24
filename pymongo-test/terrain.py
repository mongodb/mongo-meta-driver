from lettuce import world

@world.absorb
def purty(str):
	print "purty print ", str, "\n\n\nHI\n"

# transform a series of arguments. will try to match each
# basically a dispatcher, calling the registered functions
# (registered by mktransform)
world.transform_registry = []

@world.absorb
def transform(capture):


# transform decorator, used to declare transforms	
@world.absorb
def mktransform(reg_str):
	def do_transform(func):
		# if we have a match
		# call the transform function
		# return what it returns / do what it does

	# something like this
	@world.transform_registry.append(do_transform)
	return do_transform