# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  desc 'hello NAME', 'say hello to NAME'
  options from: :required, yell: :boolean
  def hello(name)
    output = []
    output << "from: #{options[:from]}" if options[:from]
    output << "Hello #{name}"
    output = output.join("\n")
    puts options[:yell] ? output.upcase : output
  end

  desc 'render CODEX_FILE', 'renders books from CODEX_FILE'
  options output: :string
  def render(codex_file)
    output = options[:output] || '/data/output'
    renderer = Renderer::Book.new(codex_filename: codex_file)
    renderer.render
  end
end
