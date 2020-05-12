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
    book = Renderer::Book.render(codex_file)
    p book
  end

  desc 'publish CODEX_FILE', 'renders and published a book from CODEX_FILE'
  def publish(codex_file)
    book = Renderer::Book.render(codex_file)
    p Api::Alexandria::BookUploader.upload(book)
  end
end
