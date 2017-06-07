require 'common_models/backward_module_name'
Syskit.warn_about_new_naming_convention
module Rock
    backward_compatible_constant :ConstantGenerator, 'Rock::Compositions::ConstantGenerator', 'models/compositions/constant_generator'
end
