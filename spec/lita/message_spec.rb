require "spec_helper"

describe Lita::Message do
  let(:user) { double("user") }

  it "stores the raw message as #body" do
    message = described_class.new("foo", user)
    expect(message.body).to eq("foo")
  end

  it "stores the user who sent the message" do
    message = described_class.new("foo", user)
    expect(message.user).to eql(user)
  end

  it "uses the body as its string representation" do
    message = described_class.new("foo", user)
    expect("#{message}").to eq("foo")
  end

  describe "#matches" do
    let(:pattern) { /([^\s]{2,})\+\+/ }

    it "returns an array of matches if there were any" do
      message = described_class.new("foo++", user)
      expect(message.matches(pattern)).to eq([["foo"]])
    end

    it "returns an empty array if there were no matches" do
      message = described_class.new("foo", user)
      expect(message.matches(pattern)).to be_empty
    end
  end

  describe "#parse_command" do
    it "parses when the message is addressed to the bot" do
      message = described_class.new("Lita foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "parses when the bot's name is prefixed with an @" do
      message = described_class.new("@Lita foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "parses when the bot's name is suffixed with a colon" do
      message = described_class.new("Lita: foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "parses when the bot's name is suffixed with a comma" do
      message = described_class.new("Lita, foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "parses when both a @ and a colon are used" do
      message = described_class.new("@Lita: foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "is not case sensitive" do
      message = described_class.new("lita foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "ignores whitespace around the bot's name and around args" do
      message = described_class.new(" lita:  foo  bar ", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "doesn't parse messages that are not addressed to the bot" do
      message = described_class.new("foo", user)
      expect(message.parse_command("Lita")).to be_nil
    end

    it "escapes messages that cannot be shellsplit as is" do
      message = described_class.new("Lita: foo 'bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "'bar"])
    end
  end
end
