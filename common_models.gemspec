# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'common_models/version'

Gem::Specification.new do |s|
  s.name = "common_models"
  s.version = CommonModels::VERSION
  s.authors = ["Sylvain Joyeux"]
  s.email = "sylvain.joyeux@m4x.org"
  s.summary = "Common models for Syskit in a Rock system"
  s.description = <<-EOD
This defines common models for Syskit integration into a Rock system. The main
part are all the base service definitions for base types. Additionally, it defines
some common generic functionality, such as the constant generator, the pose
predicates (ReachPose, MaintainPose) and the ControlLoop.
  EOD
  s.homepage = "http://rock-robotics.org"
  s.licenses = ["LGPLv2+"]

  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
end
