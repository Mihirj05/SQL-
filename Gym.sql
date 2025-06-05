CREATE DATABASE Gym;
use Gym;


-- Create Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT CHECK (age > 0)
);

-- Insert Users Data with Explicit user_id
INSERT INTO users (user_id, name, email, age) VALUES
(1, 'Nitish Kumar', 'nitish@example.com', 30),
(2, 'Rakesh', 'rakesh@example.com', 28),
(3, 'Senthil Kumar', 'senthil@example.com', 35),
(4, 'Logesh', 'logesh@example.com', 40),
(5, 'Rahul Majumdar', 'rahul@example.com', 25);

-- Create Exercises Table 
CREATE TABLE exercises (
    exercise_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE, -- Foreign Key Relationship
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    muscle_group VARCHAR(50),
    equipment VARCHAR(50)
);

-- Insert Exercises Data with user_id association
INSERT INTO exercises (user_id, name, category, muscle_group, equipment) VALUES
(1, 'Bench Press', 'Strength', 'Chest', 'Barbell'),
(2, 'Squat', 'Strength', 'Legs', 'Barbell'),
(3, 'Deadlift', 'Strength', 'Back', 'Barbell'),
(4, 'Pull-ups', 'Strength', 'Back', 'Bodyweight'),
(5, 'Bicep Curls', 'Strength', 'Arms', 'Dumbbell'),
(1, 'Running', 'Cardio', 'Legs', 'Treadmill'),
(2, 'Cycling', 'Cardio', 'Legs', 'Stationary Bike'),
(3, 'Plank', 'Core', 'Abs', 'Bodyweight'),
(4, 'Lunges', 'Strength', 'Legs', 'Dumbbell'),
(5, 'Overhead Press', 'Strength', 'Shoulders', 'Barbell'),
(1, 'Leg Press', 'Strength', 'Legs', 'Machine'),
(2, 'Dips', 'Strength', 'Triceps', 'Bodyweight'),
(3, 'Rowing', 'Cardio', 'Full Body', 'Rowing Machine'),
(4, 'Jump Rope', 'Cardio', 'Full Body', 'Rope'),
(5, 'Hanging Leg Raises', 'Core', 'Abs', 'Bodyweight');

-- Create Workout Sessions Table
CREATE TABLE workout_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    workout_date DATE NOT NULL,
    duration_minutes INT CHECK (duration_minutes > 0),
    calories_burned INT CHECK (calories_burned >= 0),
    notes TEXT,
    intensity_level VARCHAR(20)
);

-- Insert Workout Sessions Data
INSERT INTO workout_sessions (user_id, workout_date, duration_minutes, calories_burned, notes, intensity_level) VALUES
(1, '2025-03-01', 60, 500, 'Great workout!', 'High'),
(2, '2025-03-02', 45, 400, 'Felt strong today.', 'Medium'),
(3, '2025-03-03', 30, 300, 'Quick but effective.', 'Low'),
(4, '2025-03-04', 90, 700, 'Pushed my limits.', 'High'),
(5, '2025-03-05', 50, 450, 'Solid session.', 'Medium'),
(1, '2025-03-06', 70, 600, 'Endurance training.', 'High'),
(2, '2025-03-07', 40, 350, 'Focused on form.', 'Low'),
(3, '2025-03-08', 55, 480, 'Great pump.', 'Medium'),
(4, '2025-03-09', 75, 650, 'Pushed hard.', 'High'),
(5, '2025-03-10', 60, 500, 'Solid gains.', 'Medium');


# 1) Retrieve all users ?

SELECT * FROM users;

# 2) Get all workout sessions for user_id = 2 ?

SELECT * FROM workout_sessions
WHERE user_id = 2;

# 3) Count the number of workouts each user has completed ?

SELECT u.name, COUNT(ws.session_id) AS workout_count
FROM users u
LEFT JOIN workout_sessions ws ON u.user_id = ws.user_id
GROUP BY u.name
ORDER BY workout_count DESC;

# 4) Find the average duration of workouts ?

SELECT AVG(duration_minutes) AS avg_duration
FROM workout_sessions;

# 5) List all exercises in the 'Strength' category ?

SELECT * FROM exercises
WHERE category = 'Strength';

# 6) Get the top 3 users who burned the most total calories ?

SELECT u.name, SUM(ws.calories_burned) AS total_calories
FROM users u
JOIN workout_sessions ws ON u.user_id = ws.user_id
GROUP BY u.name
ORDER BY total_calories DESC
LIMIT 3;

# 7) Find the shortest and longest workout duration ?

SELECT 
    MIN(duration_minutes) AS shortest_duration,
    MAX(duration_minutes) AS longest_duration
FROM workout_sessions;

# 8) Identify the youngest and oldest user ?

SELECT 
    (SELECT name FROM users ORDER BY age ASC LIMIT 1) AS youngest_user,
    (SELECT name FROM users ORDER BY age DESC LIMIT 1) AS oldest_user;

# 9) List users who have performed 'Squat' ?

SELECT DISTINCT u.name
FROM users u
JOIN exercises e ON u.user_id = e.user_id
WHERE e.name = 'Squat';

# 10) Get all workouts on '2025-03-06' ?	

SELECT * FROM workout_sessions
WHERE workout_date = '2025-03-06';						