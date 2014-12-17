puts "current_alleles.txt"
`cat prepare_plink/hwe10e-4.bim|awk '{ print $2, $5, $6}' > current_alleles.txt`
#`cat prepare_plink/reversed_alleles.bim|awk '{ print $2, $5, $6}' > current_alleles.txt`
#puts "strand_top.list"
#`cat HumanCoreExome-12v1-0_B-b37.strand|awk '{ print $1,$6,$7 }'|sed 's/\(.*\) \(.\)\(.\)/\\1 \\2 \\3/g' > strand_top.list`

def mapsnps(file) 
	map={}
	File.open(file) do |file|
		file.each do |line|
			fields = line.chomp.split(" ")
			map[fields[0]] = fields[1..2].sort
		end
	end
	map
end

top=mapsnps("strand_top.list")
our=mapsnps("current_alleles.txt")

match = []
mismatch = []


top.keys.each do |k|
	if top[k] == our[k] then
		match << k
	else
		mismatch << k unless our[k].nil? or top[k].nil? or our[k].empty? or top[k].empty?
	end
end

File.open("mismatch.list","w") do |file|
	mismatch.each do |k|
		file.puts "#{k} #{top[k].inspect} #{our[k].inspect}"
	end
end

puts match.size.inspect
puts mismatch.size.inspect

