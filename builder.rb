require "./quiz_challenge_parser.rb"

parser = QuizChallengeParser.new

parser.parse
puts parser.parsed_questions["Word Roots"].fields["Groups"]["2"].fields["Questions"].count