# MongoDB Meta Driver Project

The MongoDB meta driver is an attempt to formally specify the client library interface for MongoDB. Eventually the documents and this specification will enhance and replace the current [MongoDB driver writing tutorial](http://www.mongodb.org/display/DOCS/Writing+Drivers+and+Tools).

In the meantime, *all* content in this repository should be considered incomplete, draft, and non-final.

## Usage

### Organization

The Meta Driver consists of two components: a specification of driver behavior, using the [Cucumber](http://cukes.info/) behavior-driven testing framework; and a reference implementation that meets the specification. The Cucumber files are located in the <tt>features/</tt> directory, and the implementation is split between the <tt>bson-ruby/</tt> submodule (BSON implementation) and the <tt>lib/</tt> directory (wire protocol and client interface).

In <tt>features/</tt>, the files with a <tt>.feature</tt> extension are the actual specifications for the driver. These are human-readable documents that describe the behavior the driver should exhibit in various scenarios. <tt>features/</tt> also contains several <tt>.rb</tt> files, which contain Ruby code specifying the step definintions, transformations, and environment setup that bridges the specifications to tests against the driver code. For more information on how this process works, see this [introduction to Cucumber and its underlying philosophy](https://blog.engineyard.com/2009/cucumber-introduction), as well as the following section.

### Running the Tests

In order to run the tests defined by the Meta Driver specifications, you will need the <tt>cucumber</tt> utility, part of the Cucumber Ruby Gem. If necessary, [install RubyGems](http://docs.rubygems.org/read/chapter/3), then run <tt>gem install cucumber</tt>, or run <tt>bundle</tt> (<tt>gem install bundle</tt> first, if necessary) at the root of the repository, to install Cucumber. Installing with <tt>bundle</tt> will pull in all the other dependencies needed by the reference driver implementation and its tests.

To run the tests with default options, navigate to the root of the repository and execute <tt>cucumber</tt>. This will run all the tests described in the <tt>features/</tt> directory. To run just a subset of the tests, execute <tt>cucumber --tags @tag1,@tag2</tt> to run tests marked with <tt>@tag1</tt> or <tt>@tag2</tt>. Many of the tests require the MongoDB server (<tt>mongod</tt>) to be running on the default port (27017) on the system the tests are being run on. Eventually server process management will be added to the testing code, so that this will not have to be done by hand; for now, it must be started manually. If the tests are run on Travis CI, the Travis configuration file provided in the repository will take care of this for you.

For more information about Cucumber, the [Cucumber wiki](https://github.com/cucumber/cucumber/wiki) is a good place to start. <tt>cucumber --help</tt> has a reasonable description of the different command-line options Cucumber supports. The Pragmatic Programmer's [*The Cucumber Book*](http://pragprog.com/book/hwcuc/the-cucumber-book) contains detailed information on using the Cucumber framework, with in-depth worked examples.

## Binding the Meta Driver Specification To Another Driver

The Meta Driver specification is designed to be usable with any language with a specification runner that supports Cucumber <tt>.feature</tt> ([Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin)) files. A partial listing of Cucumber-like frameworks for different languages can be found [here](https://github.com/cucumber/cucumber/wiki#getting-started). Even if your language is not listed there, there is a good chance a Google search will turn up something.

Here is a high-level view of the process:

- Import the Meta Driver repo as a submodule. Since the specifications are not set in stone and may have bugs when applied to particular languages, it's probably a good idea to fork the official repo first.
	- In the future the Meta Driver will be restructured to make this process easier. In particular, the reference implementation should be separate from the specifications, so that projects that need just the specifications (e.g., other language drivers) won't need to pull in a bunch of Ruby code they don't need.
- Find, install, and learn how to use a Cucumber/Gherkin implementation for your language.
- Write step definitions for your driver.
	- This is the bulk of the work. Since step definitions are essentially code in your driver's language, and different Gherkin runners embody different design decisions, your step definitions will probably look at least somewhat different from the Ruby ones in this repository.
	- That said, the overall structure of the step definitions tends to be similar between languages and implementations, so the definitions provided in this repo can still be a useful starting point. Most likely you will be following the same basic pattern as with Cucumber for Ruby: establishing a mapping between regular-expression matches against the <tt>.feature</tt> files and code that calls into your driver.
	- You should understand how [*step transforms*](https://github.com/cucumber/cucumber/wiki/Step-Argument-Transforms) work, if the implementation of Cucumber for your language supports them. If it does not, try to find one that does. Transforms are used extensively in the reference Ruby implementation, and save a large amount of code duplication.
- Run your tests, and report any bugs you find, either in your driver, or (more likely at this point) bugs or warts in the Meta Driver specification.

The Meta Driver specifications are far from a finished state, and will always be an evolving standard. Therefore, if you choose to fork this repository, it is important to keep your version of the spec in sync with the official upstream version, to ensure you are conforming to the most up-to-date version of the spec. By the same coin, if you notice inconsistencies or problems in the specification that emerge while writing the step files for your language (for instance, subtle language-dependent assumptions in the <tt>.feature</tt> files), feel free to change the features as necessary (without introducing dependencies on your language), and submit a pull request. While some slight differences in the <tt>.feature</tt> files between languages are acceptable, the specifications are more useful the more similar they all are. Ideally, the only difference between languages should be in the step files, though this may not always be possible.


## TODO

- [ ] Add launching/killing the server to Cucumber hooks so that mongod does not have to be started by hand.
- [ ] Restructure the repo, separating out the specification and implementation, to make it easier to import just the specification as a submodule.
- [ ] Expand the specifications. Particularly, add support for more advanced CRUD operations, administration, and replica-set/shard behavior.
- [ ] Expand the documentation, particularly the documentation about binding the specification for new drivers, with recommendations about how to change the <tt>.feature</tt> files when needed in such a way as not to introduce new language dependencies into the specification.