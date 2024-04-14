=begin
********************
Last names: Estrella, Homssi, Loria, Stinson
Language: Ruby 
Paradigm(s): Object-Oriented
********************
=end

module Helper
  BoolResponses = ['Y', 'N']
  DayTypeResponses = ['Normal', 'Rest', 'SNW', 'SNWH, Rest', 'Regular Holiday', 'Regular Holiday, Rest']

  def display_day_types
    puts 'Day Types:'
    DayTypeResponses.each do |i|
      print("[#{i}] ")
    end
    print("\n")
  end

  def format_time(num)
    zeroes = 4 - num.digits.count
    time = ''
    zeroes.times do
      time.insert(0, '0')
    end
    time += num.to_s
    "#{time[0, 2]}:#{time[2, 3]}"
  end

  def get_input(input_type)
    input = gets.chomp
    valid = false
    until valid
      case input_type
      when 'Y/N'
        BoolResponses.each do |i|
          valid = true if input == i
        end
      when 'Day Type'
        DayTypeResponses.each do |i|
          valid = true if input == i
        end
      when 'Number'
        valid = (input.to_i.to_s == input) && input.to_i >= 0
      when 'DayHours'
        valid = (input.to_i.to_s == input) && input.to_i >= 0 && input.to_i <= 24
      when 'Time'
        valid = (((input.to_i % 1000) % 100) < 60) && input.to_i.between?(0, 2359)
        word = input.to_i.to_s
        while word.length < 4
          word.insert(0, "0")
        end
        valid = (word == input)
        puts "Time entered is #{format_time(input.to_i)}." if valid
      when 'Menu'
        valid = input.to_i.between?(1,4)
      end
      abort 'Program exited.' if input == 'E'
      unless valid
        puts 'Invalid Input. Try again.'
        input = gets.chomp
      end
    end
    input
  end
end
