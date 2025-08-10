<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $fillable = ['name', 'email', 'country_id'];
    
    public function country() {
        return $this->belongsTo(Country::class);
    }   

    public function courses() {
        return $this->belongsToMany(Course::class);
    }
}
