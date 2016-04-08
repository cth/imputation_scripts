module Queue
	def Queue.submit
		$cfg.queue_engine.submit({
	end
end


class SlurmEngine
	def self.submit(hsh)
		`sbatch -p normal -n1 -c1 #{hsh['script']}`
	end
end
class GridEngine
	def self.submit(hsh)
		`qsub 	
	end
end
