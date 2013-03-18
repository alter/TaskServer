class TQueue
  @@queue = Array.new
  
  # add task to the first position in array
  def push(task)
    if task != nil
      @@queue.unshift(task)
    end
  end

  # get task from last position in array
  def pull()
    task_current = @@queue[-1]
    @@queue.delete_at(-1)
    return task_current
  end
    
  # return tasks as hash
  def list()
    output = {}
    @@queue.each { |task|
      output[@@queue.index(task)] = task
    }
    return output
  end

  # remove task from queue by its id and return size of queue
  def remove(number)
    @@queue.delete_at(Integer(number))
  end
  
  # return size of queue  
  def size()
    return @@queue.size
  end
end