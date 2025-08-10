<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    public function student() {
        return $this->belongsToMany(Student::class);
    }
}
