=begin
********************
Last names: Estrella, Homssi, Loria, Stinson
Language: Ruby 
Paradigm(s): Object-Oriented
********************
=end

require './helper'
include Helper

class DayInfo
  attr_accessor :in_time, :out_time, :day_type, :hrs_ns, :hrs_ot, :hrs_nsot, :day_salary

  @@day_rate = 500.00
  @@reg_hrs = 8
  @@hr_rate = @@day_rate / @@reg_hrs

  def self.day_rate
    @@day_rate
  end

  def self.day_rate=(day_rate)
    @@day_rate = day_rate
  end

  def self.reg_hrs
    @@reg_hrs
  end

  def self.reg_hrs=(reg_hrs)
    @@reg_hrs = reg_hrs
  end

  def self.hr_rate
    @@hr_rate = @@day_rate / @@reg_hrs
  end

  def initialize
    @in_time = 900
    @out_time = 900
    @day_type = 'Normal'
    @hrs_ns = 0
    @hrs_ot = 0
    @hrs_nsot = 0
    @day_salary = 0.00
  end

  def set_out_time(out_time)
    @out_time = out_time
    get_hrs
  end

  private def get_hrs
    out = @out_time < @in_time ? @out_time + 2400 : @out_time
    cur_time = @in_time / 100 + 1
    end_time = out / 100
    reg_time = cur_time + 8
    while cur_time < end_time
      cur_time += 1
      case cur_time
      when 23..28
        if cur_time > reg_time
          @hrs_nsot += 1
        else
          @hrs_ns += 1
        end
      else
        @hrs_ot += 1 if cur_time > reg_time
      end
    end
  end

  def display_day_info(day)
    puts "Work Time: #{format_time(day.in_time)} - #{format_time(day.out_time)}"
    puts "Day Type: #{day.day_type}"
    puts "Hours on Night Shift: #{day.hrs_ns}" if day.hrs_ns > 0
    puts "Hours Overtime (Night Shift Overtime): #{day.hrs_ot} (#{day.hrs_nsot})"
    puts "Day Salary: #{day.day_salary.round(2)}"
  end

  def self.display_week_info
    puts "Day Rate: #{@@day_rate.round(2)}"
    puts "Max Regular Work Hours: #{@@reg_hrs}"
    puts "Hour Rate: #{@@hr_rate.round(2)}"
  end
end

def get_dayrate_total(day_rate, day_type)
  total = 0.0

  case day_type
  when 'Normal'
    total = day_rate * 1
  when 'Rest'
    total = day_rate * 1.3
  when 'SNW'
    total = day_rate * 1.3
  when 'SNWH, Rest'
    total = day_rate * 1.5
  when 'Regular Holiday'
    total = day_rate * 2
  when 'Regular Holiday, Rest'
    total = day_rate * 2.6
  end
  total
end

def get_ot_total(hr_rate, day_type, hrs_ot, hrs_nsot)
  totalOT = 0.0
  totalNSOT = 0.0

  case day_type
  when 'Normal'
    totalOT = hrs_ot * hr_rate * 1.25
    totalNSOT = hrs_nsot * hr_rate * 1.375
  when 'Rest'
    totalOT = hrs_ot * hr_rate * 1.69
    totalNSOT = hrs_nsot * hr_rate * 1.859
  when 'SNW'
    totalOT = hrs_ot * hr_rate * 1.69
    totalNSOT = hrs_nsot * hr_rate * 1.859
  when 'SNWH, Rest'
    totalOT = hrs_ot * hr_rate * 1.95
    totalNSOT = hrs_nsot * hr_rate * 2.145
  when 'Regular Holiday'
    totalOT = hrs_ot * hr_rate * 2.6
    totalNSOT = hrs_nsot * hr_rate * 2.86
  when 'Regular Holiday, Rest'
    totalOT = hrs_ot * hr_rate * 3.38
    totalNSOT = hrs_nsot * hr_rate * 3.718
  end

  totalOT + totalNSOT
end

def get_ns_hrrate_total(hr_rate, hrs_ns)
  hrs_ns * hr_rate * 1.1
end

def prompt_week_settings
  puts 'Change Settings for the week? [Y]/[N]'
  puts 'Note that this only includes the daily rate and max regular hours.'
  input = get_input('Y/N')
  if input == 'Y'
    print "Day Rate (#{DayInfo.day_rate}): "
    DayInfo.day_rate = get_input('Number').to_f
    print "Max Regular Hours (#{DayInfo.reg_hrs}): "
    DayInfo.reg_hrs = get_input('DayHours').to_i
    DayInfo.hr_rate
    puts 'Week Settings are updated.'
  elsif input == 'N'
    puts 'Default Week Settings will be used.'
  end
end

def prompt_settings(day)
  puts 'Change Settings for today? [Y]/[N]'
  input = get_input('Y/N')
  if input == 'Y'
    puts 'Please enter a time between 00:00 and 23:59 with no semicolon.'
    print "In Time (#{format_time(day.in_time)}): "
    day.in_time = get_input('Time').to_i
    display_day_types
    print "Day Type (#{day.day_type}): "
    day.day_type = get_input('Day Type')
    puts 'Settings are updated.'
  elsif input == 'N'
    puts 'Default Day Settings will be used.'
  end
end

def confirm_rest_absence(day)
  puts 'Will you work on this rest day? [Y]/[N]'
  input = get_input('Y/N')
  return false unless input == 'N'

  day.out_time = day.in_time
  day.day_salary = DayInfo.day_rate
  puts "Day Salary (for Paid Rest Day): #{day.day_salary.round(2)}"
  true
end

def confirm_absence(day)
  puts 'Will you be absent today? [Y]/[N]'
  input = get_input('Y/N')
  return false unless input == 'Y'

  if day.day_type != 'Normal'
    day.day_salary = DayInfo.day_rate
    puts "Day Salary (for Paid Rest Day): #{day.day_salary.round(2)}"
  else
    puts "Day Salary: #{day.day_salary.round(2)}"
  end
  true
end

def prompt_out_time(day)
  print 'Out Time: '
  day.set_out_time(get_input('Time').to_i)
end

def get_day_info(day)
  prompt_settings(day)

  return if day.day_type != 'Normal' && (confirm_rest_absence(day) == true)

  puts 'Please enter a time between 00:00 and 23:59 with no semicolon.'
  loop do
    print "Minimum work hours is #{DayInfo.reg_hrs} hours. In Time is #{format_time(day.in_time)}.\n"
    prompt_out_time(day)
    out = day.out_time
    if day.in_time > out
      out += 2400
    elsif day.out_time == day.in_time
      return if confirm_absence(day) == true
    end
    break if out >= day.in_time + ((DayInfo.reg_hrs + 1) * 100)
  end

  day.day_salary += get_dayrate_total(DayInfo.day_rate, day.day_type)
  day.day_salary += get_ot_total(DayInfo.hr_rate, day.day_type, day.hrs_ot, day.hrs_nsot)
  day.day_salary += get_ns_hrrate_total(DayInfo.hr_rate, day.hrs_ns)

  puts "Day Salary: #{day.day_salary.round(2)}"
end

def get_week_info
  days = []
  weekTotal = 0

  puts 'The week will start now.'

  for i in 1..7
    puts "\nDay #{i}"
    days[i] = DayInfo.new
    if i.between?(6, 7)
      puts 'Today is a Rest day.'
      days[i].day_type = 'Rest'
    end
    get_day_info(days[i])
    weekTotal += days[i].day_salary
  end

  puts "\nThe week is over."
  puts 'Displaying Week Information:'
  DayInfo.display_week_info
  for i in 1..7
    puts "\nDay #{i}"
    days[i].display_day_info(days[i])
  end

  puts "\nWeek Salary: #{weekTotal.round(2)} (Exact Amount: #{weekTotal})"
end

def display_menu_options
  puts "\nMenu"
  puts "[1] Start a new week"
  puts "[2] Display All Default Settings"
  puts "[3] Change the week's Default Settings"
  puts "[4] Close Menu"
end

def display_menu
  input = '0'
  while input != '4'
    display_menu_options
    print 'Menu Option: '
    input = get_input('Menu')
    case input
    when '1'
      get_week_info
    when '2'
      puts "\nSettings for the Week:"
      DayInfo.display_week_info
      puts "\nSettings per Day:"
      day = DayInfo.new
      day.display_day_info(day)
    when '3'
      prompt_week_settings
    end
  end

  puts 'Menu closed.'
end

puts "\nEnter [E] to exit the program at any time."
display_menu
