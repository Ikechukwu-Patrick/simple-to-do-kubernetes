package com.awsmimicker.todoapplication.controller;

import com.awsmimicker.todoapplication.exception.ToDoBaseException;
import com.awsmimicker.todoapplication.model.ToDo;
import com.awsmimicker.todoapplication.service.ToDoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeParseException;
import java.util.List;

@RestController
public class ToDoController {


    private final ToDoService todoService;

    public ToDoController(ToDoService todoService) {
        this.todoService = todoService;
    }

    @GetMapping("/getAllTask")
    public List<ToDo> getAll() {
        return todoService.getAllTodos();
    }

    @PostMapping("/createTask")
    public ResponseEntity<ToDo> create(@RequestBody ToDo todo) {
        try {
            ToDo createdTodo = todoService.createTodo(todo);
            return new ResponseEntity<>(createdTodo, HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);  // Bad request if task is empty
        } catch (DateTimeParseException e) {
            return new ResponseEntity<>(null, HttpStatus.BAD_REQUEST);  // Bad request if date format is invalid
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);  // General error
        }
    }

    @PutMapping("/updateTask/{id}")
    public ResponseEntity<ToDo> update(@PathVariable Long id, @RequestBody ToDo updatedTodo) {
        try {
            ToDo updated = todoService.updateTodo(id, updatedTodo);
            return new ResponseEntity<>(updated, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);  // Not found if todo is not found
        }
    }

    @DeleteMapping("/deleteTask/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        try {
            todoService.deleteTodo(id);
            return new ResponseEntity<>("Task deleted successfully", HttpStatus.OK);  // No content for successful deletion
        } catch (ToDoBaseException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);  // Not found if todo is not found
        } catch (RuntimeException e) {
            return new ResponseEntity<>("An error occurred", HttpStatus.INTERNAL_SERVER_ERROR);

        }
    }
}
