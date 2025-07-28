import { reactive } from 'vue'

export const contractStore = reactive({
  contracts: [
    {
      "_id": "682b6ef3655ae984d95ecc5c",
      "answers": "[{title=Combina alimentos con vitamina C, explanation=La vitamina C mejora significativamente la absorción del hierro no-hemo (de origen vegetal). Intenta consumir frutas cítricas junto con legumbres o vegetales de hoja verde., resources=[{type=PHOTO, resourceLocator=https://ejemplo.com/imagenes/alimentos-vitamina-c.jpg}]}, {title=Evita café y té durante las comidas, explanation=Los taninos presentes en estas bebidas pueden reducir la absorción de hierro hasta en un 50%. Espera al menos una hora después de comer para consumirlas., resources=[{type=AUDIO, resourceLocator=https://ejemplo.com/audios/explicacion-nutricionista.mp3}]}]",
      "conversationRef": "QUESTION1",
      "country": "España",
      "createdAt": {"$date": "2025-05-19T17:48:35.308Z"},
      "description": "Busco consejos para mejorar la absorción de hierro de los alimentos en personas con anemia leve",
      "resources": "[{type=PHOTO, resourceLocator=https://ejemplo.com/imagenes/alimentos-ricos-hierro.jpg}, {type=VIDEO, resourceLocator=https://ejemplo.com/videos/consejos-nutricion.mp4}]",
      "title": "¿Cómo mejorar la absorción de hierro en la dieta?",
      "updatedAt": {"$date": "2025-05-19T17:48:35.308Z"}
    },
    {
      "_id": {"$oid": "683dba50f4685e8e430792a3"},
      "answers": "[{title=La IA supera en tareas específicas, no en inteligencia general, explanation=Aunque la IA puede procesar datos más rápido y superar a humanos en tareas como ajedrez o reconocimiento de patrones, carece de comprensión contextual, creatividad y inteligencia emocional que caracterizan la inteligencia humana., resources=[{type=VIDEO, resourceLocator=https://ejemplo.com/videos/comparacion-ia-humano.mp4}]}, {title=La inteligencia humana es multidimensional, explanation=Los humanos poseen inteligencia emocional, social, creativa y adaptativa que la IA actual no puede replicar. La IA excels en tareas definidas, pero los humanos destacan en situaciones ambiguas y complejas., resources=[{type=AUDIO, resourceLocator=https://ejemplo.com/audios/podcast-inteligencia-artificial.mp3}]}, {title=Colaboración, no competencia, explanation=El futuro está en la colaboración humano-IA, donde cada uno aporta sus fortalezas: la IA procesando información y los humanos aportando juicio, ética y creatividad., resources=[{type=PHOTO, resourceLocator=https://ejemplo.com/imagenes/colaboracion-humano-ia.jpg}]}]",
      "conversationRef": "QUESTION2",
      "country": "España",
      "createdAt": {"$date": "2025-06-02T14:50:56.800Z"},
      "description": "Análisis sobre las capacidades reales de la inteligencia artificial comparada con la inteligencia humana, desmitificando creencias populares",
      "resources": "[{type=VIDEO, resourceLocator=https://ejemplo.com/videos/mitos-inteligencia-artificial.mp4}, {type=PHOTO, resourceLocator=https://ejemplo.com/imagenes/cerebro-vs-chip.jpg}]",
      "title": "¿Es la inteligencia artificial más inteligente que los humanos?",
      "updatedAt": {"$date": "2025-06-02T14:50:56.800Z"}
    }
  ],

  getContractById(id) {
    return this.contracts.find(c => c._id === id || (c._id.$oid && c._id.$oid === id))
  },

  updateContract(id, data) {
    const index = this.contracts.findIndex(c => c._id === id || (c._id.$oid && c._id.$oid === id))
    if (index !== -1) {
      this.contracts[index] = { ...this.contracts[index], ...data }
    }
  }
})