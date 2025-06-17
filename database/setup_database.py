#!/usr/bin/env python3
"""
Database Setup Script for SE Course Planner
CS 348 Project - Spring 2025

This script handles database initialization, reset, and sample data loading.
"""

import mysql.connector
from mysql.connector import Error
import os
import sys
from pathlib import Path


class DatabaseManager:
    def __init__(
        self, host="localhost", user="root", password="", database="se_course_planner"
    ):
        """Initialize database connection parameters."""
        self.host = host
        self.user = user
        self.password = password
        self.database = database
        self.connection = None

    def connect(self, use_database=True):
        """Establish database connection."""
        try:
            if use_database:
                self.connection = mysql.connector.connect(
                    host=self.host,
                    user=self.user,
                    password=self.password,
                    database=self.database,
                )
            else:
                # Connect without specifying database (for creating database)
                self.connection = mysql.connector.connect(
                    host=self.host, user=self.user, password=self.password
                )

            if self.connection.is_connected():
                print(f"✅ Connected to MySQL server")
                return True

        except Error as e:
            print(f"❌ Error connecting to MySQL: {e}")
            return False

    def disconnect(self):
        """Close database connection."""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("✅ Database connection closed")

    def create_database(self):
        """Create the database if it doesn't exist."""
        try:
            if not self.connect(use_database=False):
                return False

            cursor = self.connection.cursor()

            # Create database
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {self.database}")
            print(f"✅ Database '{self.database}' created/verified")

            # Use the database
            cursor.execute(f"USE {self.database}")

            cursor.close()
            return True

        except Error as e:
            print(f"❌ Error creating database: {e}")
            return False

    def execute_sql_file(self, file_path):
        """Execute SQL commands from a file."""
        try:
            if not self.connection or not self.connection.is_connected():
                if not self.connect():
                    return False

            cursor = self.connection.cursor()

            # Read SQL file
            with open(file_path, "r", encoding="utf-8") as file:
                sql_content = file.read()

            # Remove comments and empty lines
            lines = []
            for line in sql_content.split("\n"):
                line = line.strip()
                if line and not line.startswith("--"):
                    lines.append(line)

            sql_content = " ".join(lines)

            # Smart SQL statement splitting that handles triggers
            statements = []
            current_statement = ""
            in_trigger = False

            for part in sql_content.split(";"):
                part = part.strip()
                if not part:
                    continue

                current_statement += part

                # Check if we're starting a trigger
                if "CREATE TRIGGER" in current_statement.upper():
                    in_trigger = True

                # Check if we're ending a trigger
                if in_trigger and current_statement.upper().endswith("END"):
                    statements.append(current_statement)
                    current_statement = ""
                    in_trigger = False
                elif not in_trigger:
                    statements.append(current_statement)
                    current_statement = ""
                else:
                    current_statement += "; "

            # Add any remaining statement
            if current_statement.strip():
                statements.append(current_statement)

            for statement in statements:
                statement = statement.strip()
                if statement:
                    try:
                        # Skip DELIMITER statements
                        if statement.upper().startswith("DELIMITER"):
                            continue
                        cursor.execute(statement)
                    except Error as e:
                        print(f"⚠️  Warning executing statement: {e}")
                        print(f"Statement: {statement[:100]}...")

            self.connection.commit()
            cursor.close()
            print(f"✅ Executed SQL file: {file_path}")
            return True

        except Error as e:
            print(f"❌ Error executing SQL file {file_path}: {e}")
            return False
        except FileNotFoundError:
            print(f"❌ SQL file not found: {file_path}")
            return False

    def test_connection(self):
        """Test database connection and basic queries."""
        try:
            if not self.connection or not self.connection.is_connected():
                if not self.connect():
                    return False

            cursor = self.connection.cursor()

            # Test basic queries
            test_queries = [
                ("Check students table", "SELECT COUNT(*) FROM students"),
                ("Check courses table", "SELECT COUNT(*) FROM courses"),
                ("Check requirements table", "SELECT COUNT(*) FROM requirements"),
                (
                    "Check sample student",
                    "SELECT first_name, last_name FROM students LIMIT 1",
                ),
            ]

            print("\n🧪 Running database tests:")
            for test_name, query in test_queries:
                cursor.execute(query)
                result = cursor.fetchone()
                print(f"  ✅ {test_name}: {result[0] if result else 'No result'}")

            cursor.close()
            return True

        except Error as e:
            print(f"❌ Error testing database: {e}")
            return False

    def show_sample_data(self):
        """Display sample data for verification."""
        try:
            if not self.connection or not self.connection.is_connected():
                if not self.connect():
                    return False

            cursor = self.connection.cursor()

            print("\n📊 Sample Data Overview:")

            # Students
            cursor.execute("SELECT first_name, last_name, cohort_year FROM students")
            students = cursor.fetchall()
            print(f"\n👥 Students ({len(students)}):")
            for student in students:
                print(f"  • {student[0]} {student[1]} (Cohort {student[2]})")

            # Progress summary
            cursor.execute(
                """
                SELECT first_name, last_name, courses_completed, total_credits, completion_percentage
                FROM student_progress_summary
                ORDER BY completion_percentage DESC
            """
            )
            progress = cursor.fetchall()
            print(f"\n📈 Student Progress:")
            for p in progress:
                print(
                    f"  • {p[0]} {p[1]}: {p[2]} courses, {p[3]} credits, {p[4]}% complete"
                )

            cursor.close()
            return True

        except Error as e:
            print(f"❌ Error showing sample data: {e}")
            return False


def main():
    """Main function to handle command line arguments."""
    if len(sys.argv) < 2:
        print("Usage: python setup_database.py [create|reset|test|sample]")
        print("  create: Create database and schema")
        print("  reset:  Drop and recreate everything with sample data")
        print("  test:   Test database connection and queries")
        print("  sample: Show sample data")
        return

    command = sys.argv[1].lower()

    # Database configuration - customize as needed
    config = {
        "host": "localhost",
        "user": "root",  # Change as needed
        "password": "",  # Change as needed
        "database": "se_course_planner",
    }

    # Allow environment variable overrides
    config["host"] = os.getenv("DB_HOST", config["host"])
    config["user"] = os.getenv("DB_USER", config["user"])
    config["password"] = os.getenv("DB_PASSWORD", config["password"])
    config["database"] = os.getenv("DB_NAME", config["database"])

    db_manager = DatabaseManager(**config)

    try:
        script_dir = Path(__file__).parent

        if command == "create":
            print("🚀 Creating database and schema...")
            if db_manager.create_database():
                db_manager.execute_sql_file(script_dir / "schema.sql")
                print("✅ Database and schema created successfully!")

        elif command == "reset":
            print("🔄 Resetting database with sample data...")
            if db_manager.create_database():
                if db_manager.execute_sql_file(script_dir / "schema.sql"):
                    if db_manager.execute_sql_file(script_dir / "sample_data.sql"):
                        print("✅ Database reset with sample data!")
                        db_manager.show_sample_data()

        elif command == "test":
            print("🧪 Testing database...")
            db_manager.test_connection()

        elif command == "sample":
            print("📊 Showing sample data...")
            db_manager.show_sample_data()

        else:
            print(f"❌ Unknown command: {command}")

    finally:
        db_manager.disconnect()


if __name__ == "__main__":
    main()
