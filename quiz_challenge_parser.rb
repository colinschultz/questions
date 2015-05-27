# [title] => lesson
require "./lesson.rb"
require "./group.rb"
require "./question.rb"

class QuizChallengeParser

	attr_reader :parsed_questions

	def initialize
		@parsed_questions = Hash.new
	end

	def parse
		file = File.open("/Users/cdr/Dropbox/Medical Terminology Questions/Question-Tags.txt", "r")

		current_lesson = nil
		current_group = nil
		current_question = nil
		question_number = 1

		file.each do |line|
			next if line.strip[0,1] == "#"

			line.encode!("UTF-16",  :undef => :replace, :invalid => :replace, :replace => '"')
      line.encode!("UTF-8")

			key, value = line.split("=")

			if key && value
				key = key.strip

				if key == "@L"
					if current_question
						push_question(current_group, current_question, question_number)
						question_number = 1
						current_question = nil
					end
					if current_group
						current_lesson.fields["Groups"][current_group.fields["Number"]] = current_group
						current_group = nil
					end
					if current_lesson
						@parsed_questions[current_lesson.fields["Title"]] = current_lesson
					end
					current_lesson = Lesson.new

					keys = value.split(":")
					current_lesson.fields["Unit"] = keys[0].strip
					current_lesson.fields["Lesson"] = keys[1].strip
					current_lesson.fields["Title"] = keys[2].strip
					current_lesson.fields["Groups"] = Hash.new
				elsif key == "@G"
					if current_question
						push_question(current_group, current_question, question_number)
						question_number = 1
						current_question = nil
					end

					if current_group
						current_lesson.fields["Groups"][current_group.fields["Number"]] = current_group
					end
					current_group = Group.new
					keys = value.split(":")
					current_group.fields["Number"] = keys[0].strip
					current_group.fields["Title"] = keys[1].strip
					current_group.fields["Questions"] = Hash.new
				elsif key == "@Q"
					if current_question
						push_question(current_group, current_question, question_number)
						question_number += 1
					end
					current_question = Question.new
					current_question.fields[key] = value.strip 
				else
					parse_question(key, value, current_question)
				end
			end
		end

		file.close
	end

	def parse_question(key, value, current_question)
		if key == "@D"
			if current_question.fields["@D"].is_a? Array
				current_question.fields["@D"].push(value.strip)
			else
				current_question.fields["@D"] = [value.strip]
			end
		else
			current_question.fields[key] = value.strip
		end
	end

	def push_question(current_group, current_question, question_number)
		if !current_question.fields.has_key?("@Random")
			current_question.fields["@Random"] = "Yes"
		end
		current_group.fields["Questions"][question_number] = current_question
	end

end