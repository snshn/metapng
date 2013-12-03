#!/usr/bin/ruby
#
# metapng.rb 1.0
# A command-line tool for editing metadata values of PNG images
# Licensed under Public Domain
#

require 'rubygems'
require 'chunky_png'

@filename = ARGV[0]


@separator = '  --------------------+--------------------------------------------------'
def line key, val
	len = @separator.split('+')
	puts ' | ' << key.ljust(len[0].length-4) << ' | ' << val.ljust(len[1].length-2) << ' |'
	puts @separator
end


def help
	puts ''
	puts 'Usage:'
	puts ' set <Key>           to create/modify a metadata record'
	if @image.metadata.length > 0
		puts ' mv  <Key> <New_Key> to rename a record'
		puts ' rm  <Key>           to remove a record'
	end
	puts ''
end

def set key
	if @image.metadata.include? key
		puts 'Please specify the new value for the key "' << key << '":'
	else
		puts 'Please specify the value for the new key "' << key << '":'
	end

	print '> '
	value = $stdin.gets.chomp

	@image.metadata[key] = value;
end

def rm key
	if !@image.metadata.include? key
		puts 'No such record to remove'
		cmd()
	end

	puts 'Removing key "' << key << '"...'

	@image.metadata.delete(key)
end

def mv key, new_key
	if !@image.metadata.include? key
		puts 'No such record to rename'
	end

	@image.metadata[new_key] = @image.metadata[key];
	@image.metadata.delete(key)
end

def save
	puts 'Saving file "' << @filename << '"... '
	@image.save(@filename) # Overwrite file
end

def cmd
	print '> '
	string = $stdin.gets.chomp

	return if string == ''
	args = string.split(' ')

	if !['set', 'mv', 'rm'].include? args[0]
		puts 'Please enter the proper command name (set, mv, rm)'
		cmd()
	elsif args.length < 2
		puts 'The command needs an argument' 
		cmd()
	end

	if args[0] == 'mv'
		send('mv', args[1], args[2])
	else
		send(args[0], args[1])
	end
	save()
	main()
end

def main

	if !@filename or !File.exist?(@filename) or !File.file?(@filename)
		puts 'Cannot open file "' << @filename << '"'
		exit
	end

	puts ''
	puts 'Reading file "' << @filename << '"...'

	# Accessing metadata
	@image = ChunkyPNG::Image.from_file(@filename) # TODO try/catch here to make sure it's really PNG

	puts ''
	if @image.metadata.length > 0
		puts @separator
		line('<Key>', '<Value>')
		#puts image.metadata
		for key in @image.metadata.keys.sort
			line(key.ljust(14), @image.metadata[key])
		end
	else
		puts ' [No metadata has been found in this image]'
	end
	puts ''

	puts 'What would you like to do?'
	help()
	#rm('Author')
	cmd()

end

main()

