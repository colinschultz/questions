class CreateFile

file = File.open("./original_questions.txt")

file.each_with_index do |line,index|
	puts index
end

end
