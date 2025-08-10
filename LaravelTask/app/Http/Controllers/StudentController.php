<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Student; 
use App\Http\Resources\StudentResource;

class StudentController extends Controller
{
    public function store(Request $request) {
        $validated = $request->validate([
            'name' => 'required|max:255',
            'email' => 'required|email|unique:students,email',
            'country_id' => 'required|exists:countries,id',
            'course_ids' => 'array',
            'course_ids.*' => 'exists:courses,id',
        ]);
    
        $student = Student::create($validated);

        if(!empty($validated['course_ids'])) {
            $student->courses()->attach($validated['course_ids']);
        }

        return new StudentResource($student->load(['courses', 'country']));
        // response()->json([
        //     'message' => 'Student created successfully',
        //     'student' => $student
        // ], 201);
    }
}
