#!/usr/bin/env ruby

require 'colorize'	#gem install colorize

LOCAL_PORT = 8080

class Host
	attr_accessor :name
	attr_accessor :ip
	attr_accessor :port
	attr_accessor :user
	attr_accessor :remote_tunnel_ip
	attr_accessor :remote_tunnel_port
	attr_accessor :password

	def initialize(name, ip, port = 22, user = "root", remote_tunnel_ip = "127.0.0.1", remote_tunnel_port = 80)
		@name = name
		@ip = ip
		@port = port
		@user = user
		@remote_tunnel_ip = remote_tunnel_ip
		@remote_tunnel_port = remote_tunnel_port
	end

	def print
		return "#{@name} #{@ip} #{@port}"
	end

	def setPassword(password)
		@password = password
		return self
	end
end

class String
  def is_number?
    true if Float(self) rescue false
  end
end

def readConsole
	begin		
		value = gets.chomp
	rescue Exception => e
  		exit
	end
	
	return value
end

def loadInternal
	items = Array.new

	items.push(Host.new("Some server #1", "192.168.1.1"))
	items.push(Host.new("Some server #2", "192.168.1.2"))

	items.each do |i| 
		i.name = i.ip + "\t - " + i.name
	end

	return items
end

def loadExternal
	items = Array.new


	items.push(Host.new("Some server #1", "192.168.1.3"))
	items.push(Host.new("Some server #2", "192.168.1.4"))

	return items
end


if __FILE__ == $0
	puts "Select the server:".blue

	puts "\t01-Internal 02-External".blue
	print "> "			
	value = readConsole()

	if value.is_number?
		value = Integer(value)

		case value
			when 1
				items = loadInternal()

			when 2
				items = loadExternal()
			else
				exit
		end
	end

	items.sort! { |a, b|  a.name <=> b.name }

	puts "Select the server:".blue

	items.each_with_index do |v, i| 
		message = "\t#{(i + 1).to_s.rjust(2, '0')} => #{v.name}"
		puts message.colorize(:blue)
	end

	print "> "
	value = readConsole()

	if value.is_number?
		value = Integer(value) - 1

		if items[value]
			s = items[value.to_i]

			puts "Selected server: #{s.name}".blue

			puts "Select the option:".blue
			puts "\t01-SSH 02-SCP".blue
			print "> "			
			value = readConsole()

			if value == "" 
				value = "1"
			end

			if value.is_number?
				value = Integer(value)

				case value
					when 1
						if s.password
							puts
							puts "Take care with different password!!!".colorize(:color => :white, :background => :red).blink
							puts
						end
						
						command = "ssh -p #{s.port} root@#{s.ip} -L #{LOCAL_PORT}:#{s.remote_tunnel_ip}:#{s.remote_tunnel_port}"
						puts "Connecting to '#{(value + 1).to_s.rjust(2, '0')} => #{s.name}': #{command}".colorize(:green)
						exec(command)				
					when 2
						print "LOCAL FILE> "			
						local_file = readConsole()

						if File.exist?(local_file)
							print "REMOTE FILE> "			
							remote_file = readConsole()

							if remote_file.to_s != ''
								command = "scp -P #{s.port} #{local_file} root@#{s.ip}:#{remote_file}"
								puts "Copying file to '#{(value + 1).to_s.rjust(2, '0')} => #{s.name}': #{command}".colorize(:green)
								exec(command)			
							end	
						else
							puts "File not found '#{local_file}'".colorize(:red)
						end
				end
			end
		end
	end
end
