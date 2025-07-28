<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
      elevation="2"
    >
      <v-app-bar-title class="text-h5 font-weight-bold">
        <v-icon class="mr-2">mdi-controller</v-icon>
        LevelUP
      </v-app-bar-title>
      
      <v-spacer></v-spacer>
      
      <v-btn
        variant="text"
        to="/game"
        class="mx-1"
        prepend-icon="mdi-gamepad-variant"
      >
        Game
      </v-btn>
      
      <v-btn
        variant="text"
        to="/back-office"
        class="mx-1"
        prepend-icon="mdi-briefcase"
      >
        Back Office
      </v-btn>
    </v-app-bar>

    <v-main class="grey lighten-4">
      <router-view />
    </v-main>
  </v-app>
</template>

<script setup>
</script>

<style>
.v-application {
  font-family: 'Roboto', sans-serif !important;
}
</style>