require 'sentimentalizer'

class Sentimentalizer

  def self.additional_training
    @analyser.train_positive "#{File.dirname(__FILE__)}/../../lib/additional_sentiment_training_data/positive"
    @analyser.train_negative"#{File.dirname(__FILE__)}/../../lib/additional_sentiment_training_data/negative"
  end
end

Tweetalyzer::Application.configure do
  config.after_initialize do
    Sentimentalizer.setup
    # Do additional training
    puts "Performing additional sentiment training..."
    Sentimentalizer.additional_training
    puts "Additional sentiment training complete."
  end
end
