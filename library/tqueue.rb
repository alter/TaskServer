class TQueue
  @@queue = Array.new
  
  # add task to the first position in array
  def push(task)
    if task != nil
      @@queue.unshift(task)
    end
  end

  # get task from last position in array
  def pop()
    task_current = @@queue[-1]
    @@queue.delete_at(-1)
    return task_current
  end
    
  # return tasks as hash
  def list()
    output = {}
    @@queue.each_with_index { |task, index|
      output[index] = task
    }
    return output
  end

  # remove task from queue by its id and return size of queue
  def remove(number)
    @@queue.size != 0 ? @@queue.delete_at(Integer(number)) : 0.to_s 
  end
  
  # return size of queue  
  def size()
    return @@queue.size
  end
end