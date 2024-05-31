# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lookya <lookya>                            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/04/02 15:32:05 by lookya            #+#    #+#              #
#    Updated: 2023/04/15 07:33:35 by lookya           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


CC 		= gcc
CL      = clang
CFLAGS  = -Wall -Wextra -Werror -g  # options de compilation - flags erreurs.
SRC     = $(wildcard *.c) # fichiers sources (fichiers .c répertoire src).
OBJ     = $(patsubst %.c,%.o,$(SRC)) # fichiers objets à créer.
RM      = rm -rf # supprimer les fichiers.


# SDL
#SDL_LIBS = -lmingw32 -lSDL2main -lSDL2 -lSDL2_image
SDL_OBJS = Ressources.o # contient nom fichiers objets nécessaires SDL.
SDL_CFLAGS = $(shell sdl2-config --cflags) # obtention options compilation nécessaires SDL, stocke le résultat dans la variable SDL_CFLAGS.
SDL_LIBS = $(shell sdl2-config --libs) -lSDL2_image -lSDL2_ttf -lSDL2_mixer # obtention options liens nécessaires SDL, ajoute -lSDL2_image -> lier bibliothèque.
# CFLAGS += -Dmain=SDL_main # permet renommer fonction main -> SDL_main pour que la bibliothèque SDL puisse la redéfinir.

ifeq ($(shell uname), Linux) # nom et type de l'exécutable à créer en fonction de de l'OS.
    EXEC = Programme.out
	WINDRES = /mnt/c/msys64/mingw64/bin/windres.exe
	RESSOURCES_CMD = $(WINDRES) Ressources.rc -O coff -o Ressources.o
else
    EXEC = Programme.exe
	WINDRES = C:\msys64\mingw64\bin\windres.exe
	RESSOURCES_CMD = $(WINDRES) Ressources.rc -O coff -o Ressources.o
endif

$(EXEC): $(SDL_OBJS) $(OBJ) # Règle pour créer l'exécutable.
	$(CC) $(CFLAGS) -o $@ $^ $(SDL_LIBS)

all: $(SDL_OBJS) $(EXEC)

run: all
	./$(EXEC)

sdl: $(SDL_OBJS)
ifeq ($(SDL_OBJS),)
	$(error Missing object files for SDL)
endif
	$(CC) $(SRC) $(CFLAGS) $(SDL_CFLAGS) $(SDL_OBJS) -o $(EXEC) $(SDL_LIBS) -Wl,--subsystem,console

sdl2: $(SDL_OBJS)
	$(CC) $(SRC) $(SDL_CFLAGS) $(if $(wildcard Ressources.o), Ressources.o) -o $(EXEC) $(SDL_LIBS) -Wl,--subsystem,console
asan:
	$(CL) $(CFLAGS) -fsanitize=address -fno-omit-frame-pointer -o $(EXEC) $(SRC) $(SDL_CFLAGS) -lasan $(SDL_LIBS)

clean: # supprimer les fichiers objets.
	$(RM) $(OBJ)

fclean: clean # supprimer les fichiers objets et l'exécutable.
	$(RM) $(EXEC)
	$(RM) Programme.out
	$(RM) $(SDL_OBJS)

Ressources.o: Ressources.rc
	$(RESSOURCES_CMD)

.SUFFIXES: .c .o # règle indiquant que les fichiers .c dépendent des fichiers .o

%.o: %.c # Règle pour créer les fichiers objets.
	$(CC) $(CFLAGS) -c -o $@ $<

.c.o: # générer un fichier objet à partir d'un fichier source.
	$(CC) $(CFLAGS) -c $< -o $(basename $@).o
