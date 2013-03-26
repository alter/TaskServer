class TQueue
  @@queue = {}
  
  # add task to the first position in array
  def push(id, task)
    if task != nil
      @@queue[id] = task
    end
  end

  # get task from last position in array
  def pop()
    if @@queue.first.nil?
      return
    else
      task_hash = @@queue.first
      id = task_hash[0]
      @@queue.delete(id)
      return task_hash
    end
  end
    
  # return tasks as hash
  def list()
    return @@queue
  end

  # remove task from queue by its id and return size of queue
  def remove(id)
    @@queue.size != 0 ? @@queue.delete(Integer(id)) : 0.to_s
  end

  def size
    return @@queue.size
  end
end
