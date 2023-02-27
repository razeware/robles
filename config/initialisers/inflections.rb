ActiveSupport::Inflector.inflections do |inflect|
  %w[
    RW iPhone iPad RxSwift macOS UI tvOS TV MacBook LinkedIn GCD
    raywenderlich OSX SceneKit SpriteKit CV
  ].each { |acronym| inflect.acronym(acronym) }
end
