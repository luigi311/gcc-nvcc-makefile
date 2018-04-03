# Function: Dependency
# $@ Grabs the function output left side of :
# $< grabs the function input right side of :
# Name of the final executable that can be run
EXECUTABLE = execute

# Compiler to use
CC = gcc
NVCC = nvcc

# Flags to use on compilation -g used for debugging
CFLAGS = -g -Wall
CUFLAGS = -g

# Default settings to use unless no cu files are found
LINKER = nvcc
FLAGS = $(CUFLAGS)
MATH = 

# Folder for object files
OBJDIR = ./Object
# Folder for Source files
SRCDIR = ./Source

# Header files to include
HEADERS = $(wildcard $(SRCDIR)/*.h)

# List of all the c and cu files in source folder
C_SOURCES =$(wildcard $(SRCDIR)/*.c )
CU_SOURCES=$(wildcard $(SRCDIR)/*.cu )

# List of all the object files that will be created
C_OBJS=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o , $(C_SOURCES))
CU_OBJS=$(patsubst $(SRCDIR)/%.cu, $(OBJDIR)/%.o , $(CU_SOURCES))

# Steps to run in make will skip if nothing is need to be done
all: make_directories $(EXECUTABLE)

# If no .cu files exist then use gcc to link everything together
ifeq ($(CU_SOURCES),)
	$(info No .cu files found using gcc as linker)

    LINKER = gcc
    FLAGS = $(CFLAGS)
    MATH = -lm
endif

# If the object files exist compile the object files into the
# matrix_multiplication executable
$(EXECUTABLE): $(C_OBJS) $(CU_OBJS) $(HEADERS)
	$(LINKER) $(FLAGS) $(C_OBJS) $(CU_OBJS) -o $@ $(MATH)

# Compile all the .c files in source folder into object files in object folder
$(C_OBJS): $(C_SOURCES) $(HEADERS)
	$(CC) -c $(C_SOURCES) $(CFLAGS) -lm
	mv *.o $(OBJDIR)

# Compile all the .cu files in source folder into object files in object folder
$(CU_OBJS): $(CU_SOURCES) $(HEADERS)
	$(NVCC) -c $(CU_SOURCES) $(CUFLAGS) 
	mv *.o $(OBJDIR)

# funtion to point to objects folder if it does not exist it will call mkdir
make_directories: $(OBJDIR)

# Create the directory if it does not exist
$(OBJDIR):
	mkdir -p $(OBJDIR)

# Execute the matrix_multiplication executable
run:
	./$(EXECUTABLE)
#	freemat -nogui -f "imwrite(csvread('out.csv'),'out.png')"

# Remove all the files created during Compilation
clean:
	-rm -rf $(OBJDIR)
	-rm -f $(EXECUTABLE)
#   -rm -f out.csv
#	-rm -f out.png




########################### Custom Commands ###########################

# Function to print variables out to terminal for debugging
print-%  : ; @echo $* = $($*)

# Force gcc compiler
cc : $(OBJDIR) $(C_OBJS) $(HEADERS) 
	$(CC) $(CFLAGS) $(C_OBJS) -o $(EXECUTABLE) -lm

# Force nvcc compiler
nvcc : $(OBJDIR) $(C_OBJS) $(CU_OBJS) $(HEADERS) 
	$(NVCC) $(CUFLAGS) $(C_OBJS) $(CU_OBJS) -o $(EXECUTABLE)