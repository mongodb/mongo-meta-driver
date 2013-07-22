# Copyright (C) 2013 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Defines WireElement, a collection of utility methods
# Common to the classes of wire-protocol entities

module Mongo
  module Wire
    module WireUtil
      # create chainable setter methods
      # takes a list of 3-tuples: varable name, validation predicate,
      # and error message to return if validation fails
      # predicate takes variable as an argument
      # nil predicate means no validation
      def access_with_validation(method_pred_msgs)
        method_pred_msgs.each do |m_p_m|
          method_sym, predicate, msg = m_p_m
          instance_var = "@#{method_sym}".to_sym
          getter_sym = "get_#{method_sym}".to_sym

          define_method method_sym do |val|
            if predicate.nil? or (predicate.call(val))
              instance_variable_set instance_var, val
              self
            else
              raise ArgumentError, msg
            end
          end

          define_method getter_sym do
            instance_variable_get instance_var
          end
        end
      end
    end
  end
end