package com.awsmimicker.todoapplication.service;

import com.awsmimicker.todoapplication.exception.ToDoBaseException;
import com.awsmimicker.todoapplication.model.ToDo;
import com.awsmimicker.todoapplication.repository.ToDoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ToDoService {


    @Autowired
    private ToDoRepository repository;

    public ToDoService(ToDoRepository repository){
        this.repository = repository;
    }

    public List<ToDo> getAllTodos() {
        return repository.findAll();
    }

    public ToDo createTodo(ToDo todo) {
        if (todo.getTask() == null || todo.getTask().isEmpty()) {
            throw new IllegalArgumentException("Task cannot be empty");
        }
        todo.setCreatedTime(LocalDateTime.now());
        return repository.save(todo);
    }


    public ToDo updateTodo(Long id, ToDo updatedTodo) {
        return repository.findById(id).map(todo -> {
            todo.setTask(updatedTodo.getTask());
            todo.setCompleted(updatedTodo.isCompleted());
            return repository.save(todo);
        }).orElseThrow(() -> new RuntimeException("Todo not found"));
    }

    public void deleteTodo(Long id) {
        if (!repository.existsById(id)){
            throw new ToDoBaseException("Tod Do With ID" + id + " does not exist. ");

        }
        repository.deleteById(id);
    }

}
